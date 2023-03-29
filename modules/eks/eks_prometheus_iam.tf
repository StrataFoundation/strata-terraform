resource "aws_iam_role" "prometheus_write_access" {
  count = var.monitoring_account_id != "" ? 1 : 0

  name        = "EKS-AMP-ServiceAccount-Role"
  description = "IAM role to be used by a K8s service account to assume cross account role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:monitoring:prometheus"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "monitoring_role_assumption_policy" {
  count = var.monitoring_account_id != "" ? 1 : 0

  name   = "monitoring-role-assumption-policy" 
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:iam::${var.monitoring_account_id}:role/EKS-AMP-Central-Role"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_required_iam_policy_attachment" {
  role       = aws_iam_role.prometheus_write_access.id
  policy_arn = data.aws_iam_policy.monitoring_role_assumption_policy.arn
}