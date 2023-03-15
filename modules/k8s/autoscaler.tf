resource "kubectl_manifest" "autoscaler" {
  count      = var.with_autoscaler ? length(data.kubectl_path_documents.autoscaler.documents) : 0

  yaml_body  = element(data.kubectl_path_documents.autoscaler.documents, count.index)
}