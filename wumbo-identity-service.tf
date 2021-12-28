module "wumbo_identity_service" {
  source = "./modules/service_with_lb"
  image = var.wumbo_identity_service_image
  internal = false
  name = "${var.env}-wumbo-identity-service"
  path = "${var.env}-identity.teamwumbo.com"
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
  desired_count = var.wumbo_identity_service_count
  environment = [
    {
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
      name = "TWITTER_BEARER_TOKEN",
      value = var.twitter_bearer_token
    }, {
      name = "SOLANA_URL",
      value = var.solana_url
    }, {
      name = "TWITTER_TLD",
      value = var.twitter_tld
    }, {
      name = "TWITTER_SERVICE_ACCOUNT",
      value = var.twitter_service_account
    }, {
      name = "PAYER_SERVICE_ACCOUNT",
      value = var.payer_service_account
    }
  ]
}

module "dev_wumbo_identity_service" {
  source = "./modules/service_with_lb"
  image = var.wumbo_identity_service_image
  internal = false
  name = "dev-wumbo-identity-service"
  path = "dev-identity.teamwumbo.com"
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
  desired_count = var.wumbo_identity_service_count
  environment = [
    {
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
      name = "TWITTER_BEARER_TOKEN",
      value = var.twitter_bearer_token
    }, {
      name = "SOLANA_URL",
      value = "https://api.devnet.solana.com"
    }, {
      name = "TWITTER_TLD",
      value = var.twitter_tld
    }, {
      name = "TWITTER_SERVICE_ACCOUNT",
      value = var.twitter_service_account
    }, {
      name = "PAYER_SERVICE_ACCOUNT",
      value = var.payer_service_account
    }
  ]
}
