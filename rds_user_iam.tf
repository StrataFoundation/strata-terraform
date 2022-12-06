# Nova IAM policy & role for RDS access
#
# Idea here is to create a Nova-specific user on the RDS instance for them to use in access.
# To do so, we create an cross-account AWS IAM role their account can assume. The governance
# of which resources can assume the role on their end is entirely up to them.
resource "aws_iam_role" "rds_nova_user_access_role" {
  name        = "rds_nova_user_access_role"
  description = "IAM Role for the Nova account to assume to access RDS via the nova user"
  count       = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided

  inline_policy {
    name   = "rds_nova_user_access_policy"
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
resource "aws_iam_role" "rds_hf_user_access_role" {
  name        = "rds_hf_user_access_role"
  description = "IAM Role for a K8s pod to assume to access RDS via the hf user"

  inline_policy {
    name   = "rds_hf_user_access_policy"
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
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:app" # Will need to update this with proper service account namespace and application
          }
        }
      },
    ]
  })
}