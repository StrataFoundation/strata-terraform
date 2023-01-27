provider "aws" {
  region = var.aws_region

  default_tags {
      tags = {
        Terraform = "true"
        Environment = var.env
      }
  }
}
# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# ***************************************
# VPC
# ***************************************
module "vpc" {
  source = "../modules/vpc"

  # Env
  env                             = var.env
  deploy_cost_infrastructure      = var.deploy_cost_infrastructure
  create_nova_dependent_resources = var.create_nova_dependent_resources

  # AWS
  aws_region = var.aws_region
  aws_azs    = var.aws_azs

  # VPC
  cidr_block       = var.cidr_block
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  # Nova IoT
  nova_iot_aws_account_id          = var.nova_iot_aws_account_id
  nova_iot_vpc_id                  = var.nova_iot_vpc_id
  nova_iot_vpc_private_subnet_cidr = var.nova_iot_vpc_private_subnet_cidr

  # Nova Mobile
  nova_mobile_aws_account_id          = var.nova_mobile_aws_account_id
  nova_mobile_vpc_id                  = var.nova_mobile_vpc_id
  nova_mobile_vpc_private_subnet_cidr = var.nova_mobile_vpc_private_subnet_cidr
}

# ***************************************
# EKS
# ***************************************
module "eks_oracle" {
  count = var.deploy_cost_infrastructure ? 1 : 0

  source = "../modules/eks_oracle"

  # Env
  env                             = var.env
  create_nova_dependent_resources = var.create_nova_dependent_resources

  # AWS
  aws_region = var.aws_region
  aws_azs    = var.aws_azs

}

# ***************************************
# RDS
# ***************************************
module "rds_oracle" {
  count = var.deploy_cost_infrastructure ? 1 : 0

  source = "../modules/rds_oracle"

  # Env
  env                             = var.env
  create_nova_dependent_resources = var.create_nova_dependent_resources

  # AWS
  aws_region = var.aws_region
  aws_azs    = var.aws_azs

  # RDS
  rds_instance_type    = var.rds_instance_type
  rds_storage_type     = var.rds_storage_type
  rds_storage_size     = var.rds_storage_size
  rds_max_storage_size = var.rds_max_storage_size

  # IAM
  oidc_provider     = module.eks.oidc_provider
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Networking & Security
  vpc_id                 = module.vpc.vpc_id
  ec2_bastion_private_ip = var.ec2_bastion_private_ip
  database_subnets       = var.database_subnets
  private_subnets        = var.private_subnets
  database_subnet_ids    = module.vpc.database_subnet_ids
  db_subnet_group_name   = module.vpc.database_subnet_group_name

  # Nova IoT
  nova_iot_aws_account_id            = var.nova_iot_aws_account_id
  nova_iot_vpc_id                    = var.nova_iot_vpc_id
  nova_iot_vpc_private_subnet_cidr   = var.nova_iot_vpc_private_subnet_cidr
  nova_iot_rds_access_security_group = var.nova_iot_rds_access_security_group

  # Nova Mobile
  nova_mobile_aws_account_id            = var.nova_mobile_aws_account_id
  nova_mobile_vpc_id                    = var.nova_mobile_vpc_id
  nova_mobile_vpc_private_subnet_cidr   = var.nova_mobile_vpc_private_subnet_cidr
  nova_mobile_rds_access_security_group = var.nova_mobile_rds_access_security_group

  # Monitoring
  cloudwatch_alarm_action_arns = [module.notify_slack.slack_topic_arn]

  depends_on = [
    module.vpc,
    module.notify_slack
  ]
}

# ***************************************
# Bastion
# ***************************************
module "bastion" {
  count = var.deploy_cost_infrastructure ? 1 : 0

  source = "../modules/bastion"

  # Env
  env = var.env

  # AWS
  aws_region = var.aws_region
  aws_az     = var.aws_azs[0]

  # Networking & Security
  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.vpc.public_subnets[0]
  security_group_ids = [module.rds_oracle.rds_access_security_group_id]

  # EC2
  ec2_bastion_ssh_key_name = var.ec2_bastion_ssh_key_name
  user_data                = "${path.module}/scripts/ec2_bastion_user_data.sh"
  ec2_bastion_access_ips   = var.ec2_bastion_access_ips

  # Monitoring
  cloudwatch_alarm_action_arns = [module.notify_slack.slack_topic_arn]

  depends_on = [
    module.vpc,
    module.rds_oracle,
    module.notify_slack
  ]
}

# ***************************************
# Slack Alarm Notification Infra
# ***************************************
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "oracle-alerts"
  slack_username    = "reporter"
}