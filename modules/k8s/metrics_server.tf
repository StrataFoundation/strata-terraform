resource "helm_release" "metrics-server" {
  name       = "metrics-server"

  repository = "https://charts.bitnami.com/bitnami" 
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "6.4.3"

  set {
    name  = "replicas"
    value = 2
  }

  set {
    name  = "fullnameOverride"
    value = "metrics-server"
  }

  set {
    name  = "apiService.create"
    value = "true"
  }
}