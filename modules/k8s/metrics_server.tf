resource "helm_release" "metric-server" {
  name       = "metric-server"
  repository = "https://charts.bitnami.com/bitnami" 
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "replicas"
    value = 2
  }
}