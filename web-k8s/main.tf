module "k8s" {
  source = "../modules/k8s"

  aws_region = var.aws_region
  cluster_name = var.cluster_name
  argo_path = "manifests/${var.cluster_name}/${var.stage}/cluster"
  env = var.env
  stage = var.stage
  zone_id = var.zone_id
  argo_url = var.argo_url
  zone_cert = var.zone_cert
  cidr_block = var.cidr_block
}

data "aws_iam_role" "rds_web_access_role" {
  name = "rds-web-web-user-access-role" 
}

data "aws_security_group" "rds_access_security_group" {
  name = "rds-access-security-group"
}

resource "kubernetes_service_account" "rds_web_access" {
  metadata {
    name        = "rds-web-user-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_web_access_role.arn,
    }
  }
}
