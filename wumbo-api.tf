module "wumbo_api" {
  source = "./modules/service_with_lb"
  image = var.wumbo_api_image
  internal = false
  name = "${var.env}-wumbo-api"
  path = "${var.env}-api.teamwumbo.com"
  cluster = aws_ecs_cluster.wumbo.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.team_wumbo.arn
  cpu = 400
  memory = 512
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  desired_count = var.wumbo_api_count
  environment = [
    {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }, {
      name = "AUTH0_CLIENT_ID",
      value = var.auth0_client_id
    }, {
      name = "AUTH0_CLIENT_SECRET",
      value = var.auth0_client_secret
    }, {
      name = "AUTH0_DOMAIN",
      value = var.auth0_domain
    }, {
      name = "TWITTER_KEY",
      value = var.twitter_api_key
    }, {
      name = "TWITTER_SECRET",
      value = var.twitter_secret
    }, {
      name = "TWITTER_ACCESS_TOKEN_KEY",
      value = var.twitter_access_token_key
    }, {
      name = "TWITTER_ACCESS_TOKEN_SECRET",
      value = var.twitter_access_token_secret
    }, {
      name = "SOLANA_URL",
      value = var.solana_url
    }, {
      name = "TWITTER_TLD",
      value = var.twitter_tld
    }, {
      name = "TWITTER_SERVICE_ACCOUNT",
      name = var.twitter_service_account
    }
  ]
}

