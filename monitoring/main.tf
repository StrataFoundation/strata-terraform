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

// legacy, kept for bw compatability-----
resource "aws_cloudwatch_log_group" "rpc_proxy_prod_errors" {
  name = "/CloudFlare/RPCProxy/Production/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "rpc_proxy_staging_errors" {
  name = "/CloudFlare/RPCProxy/Staging/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_metric_filter" "rpc_proxy_prod_errors_metrics_filter" {
  name           = "cloudflare-rpc-prod-errors"
  pattern        = "[ message!=\"*exceeded airdrop rate limit*\" ]"
  log_group_name = aws_cloudwatch_log_group.rpc_proxy_prod_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "CloudFlare-Prod"
    value        = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "rpc_proxy_staging_errors_metrics_filter" {
  name           = "cloudflare-rpc-staging-errors"
  pattern        = "[ message!=\"*exceeded airdrop rate limit*\" ]"
  log_group_name = aws_cloudwatch_log_group.rpc_proxy_staging_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "CloudFlare-Staging"
    value        = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "rpc_proxy_prod_errors_alarm" {
  alarm_name          = "Monitoring - RPC Proxy Prod - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Helius."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "CloudFlare-Prod"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "rpc_proxy_staging_errors_alarm" {
  alarm_name          = "Monitoring - RPC Proxy Staging - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Helius."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "CloudFlare-Staging"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}
// -----

resource "aws_cloudwatch_log_group" "helius_rpc_proxy_prod_errors" {
  name = "/CloudFlare/HeliusRPCProxy/Production/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "helius_rpc_proxy_staging_errors" {
  name = "/CloudFlare/HeliusRPCProxy/Staging/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "triton_rpc_proxy_prod_errors" {
  name = "/CloudFlare/TritonRPCProxy/Production/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "triton_rpc_proxy_staging_errors" {
  name = "/CloudFlare/TritonRPCProxy/Staging/Errors"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_metric_filter" "helius_rpc_proxy_prod_errors_metrics_filter" {
  name           = "helius-rpc-prod-errors"
  pattern        = "[ message!=\"*exceeded airdrop rate limit*\" ]"
  log_group_name = aws_cloudwatch_log_group.helius_rpc_proxy_prod_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "Helius-Prod"
    value        = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "helius_rpc_proxy_staging_errors_metrics_filter" {
  name           = "helius-rpc-staging-errors"
  pattern        = "[ message!=\"*exceeded airdrop rate limit*\" ]"
  log_group_name = aws_cloudwatch_log_group.helius_rpc_proxy_staging_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "Helius-Staging"
    value        = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "triton_rpc_proxy_prod_errors_metrics_filter" {
  name           = "triton-rpc-prod-errors"
  log_group_name = aws_cloudwatch_log_group.triton_rpc_proxy_prod_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "Triton-Prod"
    value        = 1
  }
}

resource "aws_cloudwatch_log_metric_filter" "triton_rpc_proxy_staging_errors_metrics_filter" {
  name           = "triton-rpc-staging-errors"
  log_group_name = aws_cloudwatch_log_group.triton_rpc_proxy_staging_errors.name

  metric_transformation {
    name         = "HttpsErrors"
    namespace    = "Triton-Staging"
    value        = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "helius_rpc_proxy_prod_errors_alarm" {
  alarm_name          = "Monitoring - Helius RPC Proxy Prod - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Helius."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "Helius-Prod"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "helius_rpc_proxy_staging_errors_alarm" {
  alarm_name          = "Monitoring - Helius RPC Proxy Staging - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Helius."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "Helius-Staging"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "triton_rpc_proxy_prod_errors_alarm" {
  alarm_name          = "Monitoring - Triton RPC Proxy Prod - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Triton."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "Triton-Prod"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "triton_rpc_proxy_staging_errors_alarm" {
  alarm_name          = "Monitoring - Triton RPC Proxy Staging - HTTPS Errors"
  alarm_description   = ">= 400 HTTPS status codes being received from Triton."
  metric_name         = "HttpsErrors"
  threshold           = "500"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  period              = "900" // 15 minutes
  namespace           = "Triton-Staging"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
  ok_actions          = [module.notify_slack.slack_topic_arn]
}


# ***************************************
# Slack Alarm Notification Infra
# ***************************************
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.6.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "oracle-alerts"
  slack_username    = "reporter"

  # Prevent Terraform Cloud drift on null_resource
  recreate_missing_package = false
}