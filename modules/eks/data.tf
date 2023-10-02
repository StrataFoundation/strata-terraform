data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

data "aws_iam_roles" "admin_role" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}