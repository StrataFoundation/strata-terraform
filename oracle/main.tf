provider "aws" {
  region = var.aws_region

  default_tags {
      tags = {
        Terraform = "true"
        Environment = var.env
      }
  }
}
# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "vpc" {
  source = "../modules/vpc"

  # Env
  env                             = var.env
  deploy_cost_infrastructure      = var.deploy_cost_infrastructure
  create_nova_dependent_resources = var.create_nova_dependent_resources

  # AWS
  aws_region = var.aws_region
  aws_azs    = var.aws_azs

  # VPC
  cidr_block       = var.cidr_block
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  # Nova IoT
  nova_iot_aws_account_id = var.nova_iot_aws_account_id
  nova_iot_vpc_id = var.nova_iot_vpc_id
  nova_iot_vpc_private_subnet_cidr = var.nova_iot_vpc_private_subnet_cidr

  # Nova Mobile
  nova_mobile_aws_account_id = var.nova_mobile_aws_account_id
  nova_mobile_vpc_id = var.nova_mobile_vpc_id
  nova_mobile_vpc_private_subnet_cidr = var.nova_mobile_vpc_private_subnet_cidr
}