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
  env   = var.env // in tf cloud, create add var: env = oracle
  stage = var.stage // in tf cloud, create add var: stage = sdlc
  cluster_name = var.cluster_name // in tf cloud, create add var: cluster_name = oracle-cluster

  # AWS
  aws_region = var.aws_region // in tf cloud, create add var: aws_region = us-east-1

  # VPC
  cidr_block = var.cidr_block // in tf cloud, create add var: cidr_block = 10.10.0.0/16

  # EKS/k8s
  argo_path    = "manifests/${var.cluster_name}/${var.stage}/cluster" // TODO: where does this path exist?
  zone_id      = var.zone_id // in tf cloud, create add var: zone_id = Z0569325L7XT2OOHXNLX
  argo_url     = var.argo_url // in tf cloud, create add var: argo_url = argo.oracle.test-helium.com
  zone_cert    = var.zone_cert // in tf cloud, create add var: zone_cert = arn:aws:acm:us-east-1:694730983297:certificate/5e357031-0723-40d3-9723-7475c6188824
}

data "aws_iam_role" "rds_oracle_access_role" {
  name = "rds-oracle-oracle-user-access-role" 
}

data "aws_security_group" "rds_access_security_group" {
  name = "rds-access-security-group"
}

resource "kubernetes_service_account" "rds_oracle_access" {
  metadata {
    name        = "rds-oracle-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_oracle_access_role.arn,
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