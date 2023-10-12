data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

data "aws_iam_role" "rds_web_access_role" {
  name = "rds-web-user-access-role" 
}

data "aws_iam_role" "public_monitoring_rds_access_role" {
  name = "public-monitoring-rds-access-role" 
}

data "aws_iam_role" "invalidation_role" {
  name = "invalidation-role" 
}

data "aws_security_group" "rds_access_security_group" {
  name = "rds-access-security-group"
}

data "aws_security_group" "public_rds_access_security_group" {
  name = "public-rds-access-security-group"
}