# ***************************************
# IAM Role
#
# Public Monitoring RDS access
# ***************************************
resource "aws_iam_role" "rds_monitoring_user_access_role" {
  name        = "public-monitoring-rds-access-role"
  description = "IAM Role for a K8s pod to assume to access the public monitoring RDS via the monitoring user"

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

resource "aws_iam_role" "rds_read_replica_monitoring_user_access_role" {
  name        = "public-monitoring-rds-read-replica-access-role"
  description = "IAM Role for a K8s pod to assume to access the public monitoring RDS read replica via the monitoring user"

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
            "${var.oidc_provider}:sub" = "system:serviceaccount:helium:public-monitoring-rds-read-replica-monitoring-user-access"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "public_monitoring_rds_access_policy" {
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

resource "aws_iam_policy" "public_monitoring_rds_read_replica_access_policy" {
  count = var.rds_public_read_replica ? 1 : 0

  name   = "public-monitoring-rds-read-replica-access-policy" 
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "rds-db:connect"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.public_monitoring_rds_read_replica[0].resource_id}/monitoring"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "public_monitoring_rds_access_policy_attachment" {
  role       = aws_iam_role.rds_monitoring_user_access_role.id
  policy_arn = aws_iam_policy.public_monitoring_rds_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "public_monitoring_rds_read_replica_access_policy_attachment" {
  role       = aws_iam_role.rds_read_replica_monitoring_user_access_role.id
  policy_arn = aws_iam_policy.public_monitoring_rds_read_replica_access_policy.arn
}