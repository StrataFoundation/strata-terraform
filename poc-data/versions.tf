terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.47.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
}