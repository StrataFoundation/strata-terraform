module "nft_verifier" {
  source = "./modules/service_with_lb"
  image = var.nft_verifier_image
  internal = false
  name = "${var.env}-nft-verifier"
  path = "${var.env}-nft-verifier.teamwumbo.com"
  cluster = aws_ecs_cluster.strata.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.main_domain.arn
  cpu = 512
  memory = 1028
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.strata_logs.name
  desired_count = var.nft_verifier_count
  environment = [
    {
      name = "SOLANA_URL"
      value = var.solana_url
    }, {
      name = "NAME_TLD"
      value = var.nft_verifier_tld
    }, {
      name = "SERVICE_ACCOUNT",
      value = var.nft_verifier_service_account
    }, {
      name = "MISMATCH_THRESHOLD",
      value = var.nft_verifier_mismatch_threshold
    }
  ]
}

