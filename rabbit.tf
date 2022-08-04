resource "aws_mq_broker" "rabbitmq" {
  broker_name = "rabbitmq"

  engine_type        = "RabbitMQ"
  engine_version     = "3.9.16"
  host_instance_type = "mq.m5.large"
  security_groups = [data.aws_security_group.default.id]
  subnet_ids = [module.vpc.private_subnets[0]]

  user {
    username = "strata"
    password = var.rabbit_password
  }
}
