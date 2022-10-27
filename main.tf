terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
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

locals {
  cluster_name = "${var.cluster_name}-${var.env}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = var.aws_azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

data "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id
  name   = "default"
}
