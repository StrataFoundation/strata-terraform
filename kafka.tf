resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.env}-msk-broker-logs-bucket"
  acl           = "private"
}

resource "aws_cloudwatch_log_group" "test" {
  name = "${var.env}_msk_broker_logs"
}

resource "aws_msk_configuration" "config" {
    name           = "${var.env}-config"
    server_properties = <<PROPERTIES
auto.create.topics.enable = true
default.replication.factor = 2
PROPERTIES
}

resource "aws_msk_cluster" "kafka" {
  cluster_name    = "${var.env}-kafka"
  number_of_broker_nodes = var.num_kafka_nodes
  kafka_version   = "2.6.2"

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    ebs_volume_size = var.kafka_ebs_size
    client_subnets = module.vpc.public_subnets
    security_groups = [data.aws_security_group.default.id]
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  configuration_info {
    arn = aws_msk_configuration.config.arn
    revision = aws_msk_configuration.config.latest_revision
  }

  enhanced_monitoring                 = "PER_BROKER"
}
