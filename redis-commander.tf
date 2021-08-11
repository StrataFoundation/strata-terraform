module "rediscommander" {
  source = "./modules/service_with_lb"
  internal = true
  name = "${var.env}-rediscommander"
  path = "${var.env}-redis.teamwumbo.com"
  cluster = aws_ecs_cluster.wumbo.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.team_wumbo.arn
  cpu = 256
  memory = 512
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  desired_count = 1
  image = "rediscommander/redis-commander:latest"
  environment = [
    {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }, {
      name = "PORT"
      value = "8080"
    }
  ]
}
