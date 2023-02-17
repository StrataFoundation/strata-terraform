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