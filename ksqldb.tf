module "ksql" {
  source = "./modules/service_with_lb"
  internal = true
  name = "${var.env}-ksql"
  path = "${var.env}-ksql.teamwumbo.com"
  cluster = aws_ecs_cluster.wumbo.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.public_subnets // TODO: This should work with private subnets, but for some reason fails when internal = true
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.team_wumbo.arn
  cpu = 512
  memory = 1028
  health_path = "/info"
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  desired_count = var.ksqldb_count
  image = "confluentinc/ksqldb-server:0.19.0"
  environment = [
    {
      name = "KSQL_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KSQL_LISTENERS"
      value = "http://0.0.0.0:8080/"
    }, {
      name = "KSQL_SERVICE_ID"
      value = "default_"
    }, {
      name = "KSQL_SECURITY_PROTOCOL"
      value = "SSL"
    }
  ]
}
