module "strata_api" {
  source = "./modules/service_with_lb"
  image = var.strata_api_image
  internal = false
  name = "${var.env}-strata-api"
  path = "${var.env}-api.teamwumbo.com"
  cluster = aws_ecs_cluster.strata.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.main_domain.arn
  cpu = 400
  memory = 512
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.strata_logs.name
  desired_count = var.strata_api_count
  environment = [
    {
      name = "SOLANA_URL"
      value = "${var.solana_url}"
    },
    {
      name = "PG_URL",
      value = "${aws_db_instance.default.address}"
    }, {
      name = "PG_USER",
      value = "strata"
    }, {
      name = "PG_PASSWORD",
      value = "${var.rds_password}"
    }, {
      name = "PG_DB",
      value = "strata"
    }, {
      name = "RABBIT_HOSTNAME",
      value = replace(replace(aws_mq_broker.rabbitmq.instances.0.endpoints.0, ":5671", ""), "amqps://", "")
    }, {
      name = "RABBIT_PROTOCOL",
      value = "amqps"
    }, {
      name = "RABBIT_USERNAME",
      value = "strata"
    }, {
      name = "RABBIT_PASSWORD",
      value = var.rabbit_password
    }, {
      name = "RABBIT_PORT",
      value = "5671"
    }
  ]
}

