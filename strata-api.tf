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
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}

