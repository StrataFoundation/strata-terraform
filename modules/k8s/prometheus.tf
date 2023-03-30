resource "helm_release" "prometheus" {
  count = var.with_central_monitoring ? 1 : 0

  name             = "prometheus"
  chart            = "prometheus"
  version          = "20.0.2"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true
  cleanup_on_fail  = true 
}

resource "kubectl_manifest" "prometheus" {
  count      = var.with_central_monitoring ? length(data.kubectl_path_documents.prometheus.documents) : 0

  depends_on = [helm_release.prometheus]
  yaml_body  = element(data.kubectl_path_documents.prometheus.documents, count.index)
}
