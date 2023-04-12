# ***************************************
# IAM Role
#
# Public Monitoring RDS access
# ***************************************
resource "aws_iam_role" "rds_monitoring_user_access_role" {
  name        = "public-monitoring-rds-access-role"
  description = "IAM Role for a K8s pod to assume to access the public monitoring RDS via the monitoring user"

  inline_policy {
    name   = "public-monitoring-rds-access-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.public_monitoring_rds.resource_id}/monitoring"
          ]
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${var.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:helium:public-monitoring-rds-monitoring-user-access"
          }
        }
      },
    ]
  })
}