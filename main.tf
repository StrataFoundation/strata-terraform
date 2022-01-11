terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
      tags = {
        Terraform = "true"
        Environment = var.env
      }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = var.aws_azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# module "vpn" {
#   source="./modules/vpn"
#   aws_region = var.aws_region
#   vpn_name = "${var.env}-strata-vpn"
#   ovpn_users = var.ovpn_users
#   vpc_id = module.vpc.vpc_id
#   subnet_id = module.vpc.public_subnets[0]
#   security_groups = [data.aws_security_group.default.id]
# }

data "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id
  name   = "default"
}
