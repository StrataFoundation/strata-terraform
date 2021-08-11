variable "aws_region" { default = "us-east-1" }
variable "ovpn_users" { 
  type = list(string)
  default = ["tf-ovpn"] 
  }
variable "vpn_name" { default = "tf-ovpn" }
variable "ec2_username" {
  type = string
  default = "ec2-user"
}
variable "ovpn_config_directory" {
  description = "The name of the directory to eventually download the OVPN configuration files to"
  default     = "generated/ovpn-config"
}
variable "openvpn_install_script_location" {
  description = "The location of an OpenVPN installation script compatible with https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
  default     = "https://raw.githubusercontent.com/dumrauf/openvpn-install/master/openvpn-install.sh"
}

variable "security_groups" {
  type = list(string)
}

variable "stack_item_fullname" {
  type        = string
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
  default     = "OpenVPN VPC Quick Start"
}

variable "stack_item_label" {
  type        = string
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
  default     = "openvpn_quickstart"
}

variable "keyfile_name" {
  type        = string
  description = "SSH keyfile name"
  default = "ec2-key"
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

data "aws_caller_identity" "current" {}

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
}

resource "aws_key_pair" "terraformer" {
  key_name   = "terraform-openvpn-key"
  public_key = "${tls_private_key.keypair.public_key_openssh}"
}

resource "local_file" "key" {
  content     = "${tls_private_key.keypair.private_key_pem}"
  filename = "${path.module}/${var.keyfile_name}"
  file_permission = "0600"
}

resource "local_file" "pub" {
  content     = "${tls_private_key.keypair.public_key_openssh}"
  filename = "${path.module}/${var.keyfile_name}.pub"
}

resource "null_resource" "chmod_privatekey" {
  depends_on = [local_file.key]

  provisioner "local-exec" {
    command = "chmod 400 ${path.module}/${var.keyfile_name}"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "openvpn" {
  ami               = "${data.aws_ami.amazon_linux_2.id}"
  instance_type     = "t2.nano"
  monitoring        = false
  key_name          = "${aws_key_pair.terraformer.key_name}"
  subnet_id = var.subnet_id
  tags = {
    application = "${var.stack_item_fullname}"
    account_id = "${data.aws_caller_identity.current.account_id}"
    caller_arn = "${data.aws_caller_identity.current.arn}"
    caller_id  = "${data.aws_caller_identity.current.user_id}"
    Name        = "${var.stack_item_label}"
  }
  vpc_security_group_ids = concat(["${aws_security_group.openvpn.id}"], var.security_groups)
}

resource "aws_security_group" "openvpn" {
  name = "openvpn"
  description = "openvpn security groups"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "vpn-clients" {
  type            = "ingress"
  from_port       = 1194
  to_port         = 1194
  protocol        = "udp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.openvpn.id}"
}

resource "aws_security_group_rule" "main_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.openvpn.id}"
}

resource "aws_security_group_rule" "ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.openvpn.id}"
}

resource "aws_eip" "openvpn" {
  instance = "${aws_instance.openvpn.id}"
}

resource "null_resource" "openvpn_bootstrap" {
  connection {
    type        = "ssh"
    host        = aws_instance.openvpn.public_ip
    user        = var.ec2_username
    port        = "22"
    private_key = file("${path.module}/${var.keyfile_name}")
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "curl -O ${var.openvpn_install_script_location}",
      "chmod +x openvpn-install.sh",
      <<EOT
      sudo AUTO_INSTALL=y \
           APPROVE_IP=${aws_instance.openvpn.public_ip} \
           ENDPOINT=${aws_instance.openvpn.public_dns} \
           ./openvpn-install.sh
      
EOT
      ,
    ]
  }
}


resource "null_resource" "openvpn_update_users_script" {
  depends_on = [null_resource.openvpn_bootstrap]

  triggers = {
    ovpn_users = join(" ", var.ovpn_users)
  }

  connection {
    type        = "ssh"
    host        = aws_instance.openvpn.public_ip
    user        = var.ec2_username
    port        = "22"
    private_key = file("${path.module}/${var.keyfile_name}")
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_users.sh"
    destination = "/home/${var.ec2_username}/update_users.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~${var.ec2_username}/update_users.sh",
      "sudo ~${var.ec2_username}/update_users.sh ${join(" ", var.ovpn_users)}",
    ]
  }
}


resource "aws_s3_bucket" "ovpn" {
  bucket = "${var.vpn_name}-keys"
  acl = "private"
}

resource "null_resource" "remove_and_upload_to_s3" {
  depends_on = [null_resource.openvpn_update_users_script]
  provisioner "local-exec" {
    command = <<EOT
    mkdir -p ${var.ovpn_config_directory};
    scp -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${path.module}/${var.keyfile_name} ${var.ec2_username}@${aws_instance.openvpn.public_ip}:/home/${var.ec2_username}/*.ovpn ${var.ovpn_config_directory}/
    aws s3 sync ${var.ovpn_config_directory} s3://${aws_s3_bucket.ovpn.id}
EOT
  }
}
