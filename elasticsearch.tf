
module "cognito" {
  source     = "./modules/cognito"
  region = var.aws_region
  name = "${var.env}-strata"
  cognito_domain = "${var.env}-strata"
}

data "aws_iam_policy_document" "cognito_es_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DescribeUserPoolClient",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUserPoolClients",
      "cognito-identity:DescribeIdentityPool",
      "cognito-identity:UpdateIdentityPool",
      "cognito-identity:SetIdentityPoolRoles",
      "cognito-identity:GetIdentityPoolRoles"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "es_assume_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "cognito_es_policy" {
  name = "${var.env}-STRATA-COGNITO-ACCESS-ES-POLICY"
  policy = data.aws_iam_policy_document.cognito_es_policy.json
}


resource "aws_iam_role" "cognito_es_role" {
  name = "${var.env}-STRATA-COGNITO-ACCESS-ES-ROLE"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy.json

}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  role       = aws_iam_role.cognito_es_role.name
  policy_arn = aws_iam_policy.cognito_es_policy.arn
}

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
  iam_role_arns =  ["${lookup(module.cognito.cognito_map, "auth_arn")}"]
  iam_actions = ["es:*"]
  cognito_authentication_enabled = true
  cognito_user_pool_id = lookup(module.cognito.cognito_map, "user_pool")
  cognito_identity_pool_id = lookup(module.cognito.cognito_map, "identity_pool")
  cognito_iam_role_arn = aws_iam_role.cognito_es_role.arn

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}
