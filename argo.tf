resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.8.3"
  create_namespace = true

  set {
    name = "server.insecure"
    value = "true"
  }

  set {
    name = "server.ingress.enabled"
    value = "true"
  }

  set {
    name = "server.ingress.hosts[0]"
    value = "argocd.test-helium.com"
  }

  set {
    name = "server.ingress.ingressClassName"
    value = "nginx"
  }
}

data "kubectl_path_documents" "application" {
    pattern = "./argocd/application.yaml"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [helm_release.argocd]
  count      = length(data.kubectl_path_documents.application.documents)
  yaml_body  = element(data.kubectl_path_documents.application.documents, count.index)
}
