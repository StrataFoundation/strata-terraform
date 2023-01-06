terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.47.0"
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