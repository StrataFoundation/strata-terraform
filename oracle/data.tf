data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}