provider "aws" {
  region = var.aws_region

  default_tags {
      tags = {
        Terraform = "true"
        Environment = var.stage
      }
  }
}

# ***************************************
# VPC
# ***************************************
module "vpc" {
  source = "../modules/vpc"

  # Env
  deploy_cost_infrastructure = var.deploy_cost_infrastructure

  # AWS
  aws_region = var.aws_region
  aws_azs    = var.aws_azs

  # VPC
  vpc_name           = var.vpc_name
  cidr_block         = var.cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}-${var.stage}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}-${var.stage}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# ***************************************
# EKS
# ***************************************
module "eks" {
  count = var.deploy_cost_infrastructure ? 1 : 0

  source = "../modules/eks"

  # Env
  env   = var.env
  stage = var.stage

  # AWS
  aws_region = var.aws_region

  # VPC
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  cidr_block  = var.cidr_block

  # EKS
  cluster_name                    = var.cluster_name
  cluster_node_name               = "small-node-group"
  cluster_version                 = var.cluster_version
  cluster_min_size                = var.cluster_min_size
  cluster_max_size                = var.cluster_max_size
  cluster_desired_size            = var.cluster_desired_size
  eks_instance_type               = var.eks_instance_type
  manage_aws_auth_configmap       = var.manage_aws_auth_configmap
  add_cluster_autoscaler          = var.add_cluster_autoscaler
  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    attach_cluster_primary_security_group = true
    create_security_group                 = false # Disabling and using externally provided security groups
  }
  node_security_group_tags        = {
    "kubernetes.io/cluster/${var.cluster_name}-${var.stage}" = null
  }

  # Centralized Monitoring
  monitoring_account_id = var.monitoring_account_id
}

# ***************************************
# Slack Alarm Notification Infra
# ***************************************
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.6.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "oracle-alerts"
  slack_username    = "reporter"
}