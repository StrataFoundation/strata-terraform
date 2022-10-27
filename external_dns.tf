module "external_dns_helm" {
  source  = "lablabs/eks-external-dns/aws"
  version = "1.1.0"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks.eks_cluster_identity_oidc_issuer_arn

  policy_allowed_zone_ids = var.zone_ids

  helm_release_name = "aws-ext-dns-helm"
  namespace         = "aws-external-dns-helm"
}
