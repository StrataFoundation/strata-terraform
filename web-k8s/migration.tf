# ***************************************
# K8s Service Account
# ***************************************
data "aws_iam_role" "migration_access_role" {
  name = "migration-access-role" 
}

resource "kubernetes_service_account" "migration_access" {
  metadata {
    name        = "rds-migration-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.migration_access_role.arn,
    }
  }
}