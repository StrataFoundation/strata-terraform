# Used for checking out kafka

module "kowl" {
  source = "./modules/service_with_lb"
  internal = true
  name = "${var.env}-kowl"
  path = "${var.env}-kowl.teamwumbo.com"
  cluster = aws_ecs_cluster.wumbo.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.team_wumbo.arn
  cpu = 256
  memory = 512
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  desired_count = 1
  image = "quay.io/cloudhut/kowl:master"
  environment = [
    {
      name = "KAFKA_BROKERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_TLS_ENABLED"
      value = "true"
    }
  ]
}

module "kafka_manager" {
  source = "./modules/service_with_lb"
  command = ["-Dhttp.port=8080"]
  internal = true
  name = "${var.env}-kafka-manager"
  path = "${var.env}-kafka-manager.teamwumbo.com"
  cluster = aws_ecs_cluster.wumbo.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.team_wumbo.arn
  cpu = 256
  memory = 512
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  desired_count = 1
  image = "hlebalbau/kafka-manager:stable"
  environment = [
    {
      name = "ZK_HOSTS"
      value = aws_msk_cluster.kafka.zookeeper_connect_string
    }
  ]
}
