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
  elasticsearch_version   = "7.16.2"
  instance_type           = "t2.small.elasticsearch"
  instance_count          = 3
  ebs_volume_size         = 10
  encrypt_at_rest_enabled = true
  kibana_subdomain_name   = "kibana-es"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}
