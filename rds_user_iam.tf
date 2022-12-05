# Nova IAM policy & role
#
# Idea here is to create a Nova-specific user on the RDS instance for them to use in access.
# To do so, we create an cross-account AWS IAM role their account can assume. The governance
# of which resources can assume the role on their end is entirely up to them.
# resource "aws_iam_role" "nova_rds_role" {
#   name = "nova_rds_role"
#   description = "IAM Role for the Nova account to assume to access RDS via the nova user"

#   inline_policy {
#     name = "nova_rds_user_access_policy"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = [
#             "rds-db:connect"
#           ]
#           Effect   = "Allow"
#           Resource = [
#             "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.oracle_rds.resource_id}/nova"
#           ]
#         },
#       ]
#     })
#   }

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           AWS = "arn:aws:iam::${var.nova_aws_account_id}:root"
#         }
#       },
#     ]
#   })
# }