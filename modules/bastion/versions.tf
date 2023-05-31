terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
}