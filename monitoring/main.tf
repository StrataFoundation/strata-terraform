provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform = "true"
      Environment = var.stage
    }
  }
}

# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = try(module.eks[0].cluster_endpoint, null)
  cluster_ca_certificate = try(base64decode(module.eks[0].cluster_certificate_authority_data), null)
  token                  = try(module.eks[0].aws_eks_cluster_auth, null)
}

# ***************************************
# Prometheus
# ***************************************
resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/aws/prometheus/eks"
  retention_in_days = 14
}

resource "aws_prometheus_workspace" "prometheus_eks_metrics" {
  alias = "eks-monitoring"

  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prometheus.arn}:*"
  }
}

# ***************************************
# IAM
# ***************************************
resource "aws_iam_role" "prometheus_write_access" {
  name        = "EKS-AMP-Central-Role"
  description = "IAM Role allowing cross-account write access to Prometheus"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = local.iam_roles_receiving_write_permission_to_amp
        }
      },
    ]
  })
}