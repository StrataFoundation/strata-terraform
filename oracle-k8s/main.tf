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
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

module "k8s" {
  source = "../modules/k8s"

  # Env
  env   = var.env 
  stage = var.stage 
  cluster_name = var.cluster_name 

  # AWS
  aws_region = var.aws_region

  # VPC
  cidr_block = var.cidr_block

  # EKS/k8s
  argo_path       = var.argo_path
  zone_id         = var.zone_id 
  argo_url        = var.argo_url
  zone_cert       = var.zone_cert
  with_autoscaler = var.with_autoscaler
}

data "aws_security_group" "rds_access_security_group" {
  name = "rds-access-security-group"
}

data "aws_iam_role" "rds_mobile_oracle_access_role" {
  name = "rds-mobile-oracle-user-access-role" 
}

resource "kubernetes_service_account" "rds_mobile_oracle_access" {
  metadata {
    name        = "rds-mobile-oracle-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_mobile_oracle_access_role.arn,
    }
  }
}

data "aws_iam_role" "rds_iot_oracle_access_role" {
  name = "rds-iot-oracle-user-access-role" 
}

resource "kubernetes_service_account" "rds_iot_oracle_access" {
  metadata {
    name        = "rds-iot-oracle-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_iot_oracle_access_role.arn,
    }
  }
}

data "aws_iam_role" "rds_metadata_access_role" {
  name = "rds-metadata-user-access-role" 
}

resource "kubernetes_service_account" "rds_metadata_access" {
  metadata {
    name        = "rds-metadata-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_metadata_access_role.arn,
    }
  }
}


resource "kubectl_manifest" "rds-access-security-group-policy" {
    yaml_body = <<YAML
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  name: rds-access-security-group-policy
  namespace: helium
spec:
  podSelector: 
    matchLabels: 
      security-group: rds-access
  securityGroups:
    groupIds:
      - "${data.aws_security_group.rds_access_security_group.id}"
      - "${data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id}"
YAML
}