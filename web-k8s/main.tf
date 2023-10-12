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

  # K8s - Argo
  argo_path            = "manifests/${var.cluster_name}/${var.stage}/cluster"
  argo_admin1          = var.argo_admin1
  argo_admin2          = var.argo_admin2
  argo_admin3          = var.argo_admin3
  argo_admin4          = var.argo_admin4
  argo_admin5          = var.argo_admin5
  argo_admin6          = var.argo_admin6
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  zone_id              = var.zone_id
  argo_url             = var.argo_url
  zone_cert            = var.zone_cert

  # K8s -Autoscaling
  with_autoscaler = var.with_autoscaler

  # K8s - Monitoring
  with_central_monitoring     = var.with_central_monitoring
  monitoring_account_id       = var.monitoring_account_id
  monitoring_account_region   = var.monitoring_account_region
  prometheus_remote_write_url = var.prometheus_remote_write_url
}

resource "kubernetes_service_account" "rds_web_access" {
  metadata {
    name        = "rds-web-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_web_access_role.arn,
    }
  }
}

resource "kubernetes_service_account" "public_monitoring_rds_monitoring_user_access" {
  metadata {
    name        = "public-monitoring-rds-monitoring-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.public_monitoring_rds_access_role.arn,
    }
  }
}

resource "kubernetes_service_account" "invalidation_role" {
  metadata {
    name        = "invalidation-role"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.invalidation_role.arn,
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

resource "kubectl_manifest" "public-rds-access-security-group-policy" {
    yaml_body = <<YAML
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  name: public-rds-access-security-group-policy
  namespace: helium
spec:
  podSelector: 
    matchLabels: 
      security-group: public-rds-access
  securityGroups:
    groupIds:
      - "${data.aws_security_group.public_rds_access_security_group.id}"
      - "${data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id}"
YAML
}