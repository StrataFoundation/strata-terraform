module "elasticsearch" {
  source = "cloudposse/elasticsearch/aws"
  namespace               = "eg"
  stage                   = var.env
  name                    = "es"
  dns_zone_id             = var.zone_id
  security_groups = [data.aws_security_group.default.id]
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.public_subnets
  zone_awareness_enabled  = "true"
  elasticsearch_version   = "7.10"
  instance_type           = "t2.small.elasticsearch"
  availability_zone_count = 3
  instance_count          = 4
  ebs_volume_size         = 10
  encrypt_at_rest_enabled = false
  kibana_subdomain_name   = "${var.env}-kibana"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}
