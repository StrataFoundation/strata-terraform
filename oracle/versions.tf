terraform {
  cloud {
    organization = "helium-foundation"

    workspaces {
      name = "oracle-sdlc-aws"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "<= 5.0"
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