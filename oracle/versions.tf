terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.47.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
}