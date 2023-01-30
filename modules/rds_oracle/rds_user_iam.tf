# ***************************************
# IAM Role
#
# Nova IAM policy & role for RDS access
#
# These IAM roles allow cross-account access to the postgres db for nova_<iot/mobile> users. Nova Labs
# IoT and Mobile AWS accounts can assume these roles in order to access the postgres db as the db-defined 
# nova_<iot/mobile> users.
# ***************************************
resource "aws_iam_role" "rds_nova_user_access_role" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  name        = "rds-nova-${each.key}-user-access-role"
  description = "IAM Role for the Nova ${each.value.label} account to assume to access RDS via the ${each.value.user} user"

  inline_policy {
    name   = "rds-nova-${each.key}-user-access-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/${each.value.user}"
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
          AWS = "arn:aws:iam::${each.value.account_id}:root"
        }
      },
    ]
  })
}

# ***************************************
# IAM Role
#
# Helium Foundation IAM policy & role for RDS access
#
# These IAM roles allow k8s access to the postgres db for a <active_device/mobile>_oracle user. Any k8s pod
# (e.g., ideally the <active-device/mobile>-oracle pod) with the proper k8s "service account" definition will
# be able to assume these roles in order to access the postgres db as the db-defined <active_device/mobile>_oracle user.
# ***************************************
resource "aws_iam_role" "rds_foundation_user_access_role" {
  for_each = local.foundation

  name        = "rds-${each.key}-oracle-user-access-role"
  description = "IAM Role for a K8s pod to assume to access RDS via the ${each.value.user} user"

  inline_policy {
    name   = "rds-${each.key}-oracle-user-access-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/${each.value.user}"
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
            "${var.oidc_provider}:sub" = "system:serviceaccount:${var.eks_cluster_name}:rds-${each.key}-oracle-user-access"
          }
        }
      },
    ]
  })
}