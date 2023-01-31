data "aws_eks_cluster_auth" "eks" {
  name = module.eks_oracle[0].cluster_id
}