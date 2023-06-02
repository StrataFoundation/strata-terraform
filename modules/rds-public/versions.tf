terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.0.1"
    }
    local = {
      version = "~> 2.1"
    }
  }
}