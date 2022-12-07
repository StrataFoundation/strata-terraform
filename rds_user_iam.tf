# Nova IAM policy & role for RDS access
#
# This IAM role allows cross-account access to the postgres db for a nova user. In sum, a Nova Labs
# AWS account can assume this role in order to access the postgres db as the db-defined nova user.
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
#
# This IAM role allows k8s access to the postgres db for an mobile_oracle user. Any k8s pod (e.g., ideally the mobile_oracle pod) with the proper 
# k8s "service account" definition will be able to assume this role in order to access the postgres db as the db-defined mobile_oracle user.
resource "aws_iam_role" "rds_mobile_oracle_user_access_role" {
  name        = "rds_mobile_oracle_user_access_role"
  description = "IAM Role for a K8s pod to assume to access RDS via the mobile_oracle user"

  inline_policy {
    name   = "rds_mobile_oracle_user_access_policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/mobile_oracle"
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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:rds_mobile_oracle_user_access"
          }
        }
      },
    ]
  })
}

# This IAM role allows k8s access to the postgres db for an active_device_oracle user. Any k8s pod (e.g., ideally the active_device_oracle pod) with the proper 
# k8s "service account" definition will be able to assume this role in order to access the postgres db as the db-defined active_device_oracle user.
resource "aws_iam_role" "rds_active_device_oracle_user_access_role" {
  name        = "rds_active_device_oracle_user_access_role"
  description = "IAM Role for a K8s pod to assume to access RDS via the active_device_oracle user"

  inline_policy {
    name   = "rds_active_device_oracle_user_access_policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/active_device_oracle"
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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:rds_active_device_oracle_user_access"
          }
        }
      },
    ]
  })
}