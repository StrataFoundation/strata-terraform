provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform = "true"
      Environment = "all"
    }
  }
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

# ***************************************
# Grafana
# ***************************************
resource "aws_grafana_workspace" "grafana" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["PROMETHEUS"] 
  role_arn                 = aws_iam_role.grafana_amp_access.arn
}

resource "aws_iam_role" "grafana_amp_access" {
  name        = "Grafana-AMP-Access-Role"
  description = "IAM Role allowing Grafana to read from AMP"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonPrometheusFullAccess"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

# ***************************************
# CloudWatch - RPC Proxy
# ***************************************
resource "aws_cloudwatch_log_group" "rpc_proxy_prod_errors" {
  name = "/CloudFlare/RPCProxy/Production/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "rpc_proxy_stagging_errors" {
  name = "/CloudFlare/RPCProxy/Staging/Errors"
  retention_in_days = 14
}