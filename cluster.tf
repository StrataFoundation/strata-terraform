
resource "aws_kms_key" "strata_logs" {
  description             = "strata logs"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "strata_logs" {
  name = "${var.env}-strata-logs"
}

resource "aws_ecs_cluster" "strata" {
  depends_on = [
    null_resource.iam_wait
  ]

  name = "${var.env}-strata-cluster"
  capacity_providers = [aws_ecs_capacity_provider.cluster_cap_provider.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cluster_cap_provider.name
    weight = 100
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.strata_logs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.strata_logs.name
      }
    }
  }
}

resource "aws_placement_group" "placement_group" {
  name     = "${var.env}-strata"
  strategy = "cluster"
}
resource "aws_autoscaling_group" "cluster_asg" {
  name = "${var.env}-strata-asg"

  max_size = var.cluster_max_size
  min_size = "1"
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  placement_group = aws_placement_group.placement_group.id
  launch_configuration = aws_launch_configuration.main.id
  vpc_zone_identifier = module.vpc.private_subnets
  timeouts {
    delete = "15m"
  }

  tag {
        key                 = "AmazonECSManaged"
        value = ""
        propagate_at_launch = true
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

locals {
  strata_keypair_name = "${var.env}-strata-cluster-key"
}

resource "tls_private_key" "cluster_keypair" {
  algorithm = "RSA"
}


resource "aws_key_pair" "cluster_keypair" {
  key_name   = local.strata_keypair_name
  public_key = "${tls_private_key.cluster_keypair.public_key_openssh}"
}

resource "local_file" "cluster_priv" {
  content     = "${tls_private_key.cluster_keypair.private_key_pem}"
  filename = "${path.module}/keys/${local.strata_keypair_name}"
  file_permission = "0600"
}


resource "local_file" "cluster_pub" {
  content     = "${tls_private_key.cluster_keypair.public_key_openssh}"
  filename = "${path.module}/keys/${local.strata_keypair_name}.pub"
  file_permission = "0600"
}

resource "aws_s3_bucket" "keys" {
  bucket = "${var.env}-strata-cluster-keys"
  acl = "private"
}

resource "null_resource" "upload_cluster_key_to_s3" {
  provisioner "local-exec" {
    command = <<EOT
    aws s3 sync ${path.module}/keys s3://${aws_s3_bucket.keys.id}
EOT
  }
}


resource "aws_launch_configuration" "main" {
  depends_on = [
    null_resource.iam_wait
  ]

  name_prefix = "${var.env}-strata-launch-config"

  iam_instance_profile = aws_iam_instance_profile.cluster.name
  instance_type = var.instance_type
  security_groups = [data.aws_security_group.default.id]
  image_id      = data.aws_ami.ecs_ami.image_id
  associate_public_ip_address = true
  key_name = aws_key_pair.cluster_keypair.key_name

  root_block_device {
    volume_type = "standard"
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "standard"
    encrypted   = true
  }

  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${var.env}-strata-cluster' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "cluster_cap_provider" {
  name = "${var.env}-strata-cap-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cluster_asg.arn
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}
