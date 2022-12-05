# Nova IAM policy & role for RDS access
#
# Idea here is to create a Nova-specific user on the RDS instance for them to use in access.
# To do so, we create an cross-account AWS IAM role their account can assume. The governance
# of which resources can assume the role on their end is entirely up to them.
resource "aws_iam_role" "nova_rds_role" {
  name        = "nova_rds_role"
  description = "IAM Role for the Nova account to assume to access RDS via the nova user"
  count       = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided

  inline_policy {
    name   = "nova_rds_user_access_policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/nova"
          ]
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${var.nova_aws_account_id}:root"
        }
      },
    ]
  })
}

# Helium Foundation IAM policy & role for RDS access
resource "aws_iam_openid_connect_provider" "open_id" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [module.eks.cluster_tls_certificate_sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_role" "hf_rds_role" {
  name        = "hf_rds_role"
  description = "IAM Role for the K8s pod to assume to access RDS via the hf user"

  inline_policy {
    name   = "hf_rds_user_access_policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/hf"
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
          Federated = "${aws_iam_openid_connect_provider.open_id.arn}"
        }
        Condition = {
          StringEqual = {
            "${replace("${aws_iam_openid_connect_provider.open_id.url}", "https://", "")}:aub" = "sts:amazonaws.com"
            "${replace("${aws_iam_openid_connect_provider.open_id.url}", "https://", "")}:sub" = "system:serviceaccount:default:app"
          }
        }
      },
    ]
  })
}