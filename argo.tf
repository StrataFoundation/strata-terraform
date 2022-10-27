provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.8.3"
  create_namespace = true
}

data "kubectl_path_documents" "application" {
    pattern = "./argo/application.yaml"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [helm_release.argocd]
  count      = length(data.kubectl_path_documents.application.documents)
  yaml_body  = element(data.kubectl_path_documents.application.documents, count.index)
}
