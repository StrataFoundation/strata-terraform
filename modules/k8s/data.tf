data "kubectl_path_documents" "nginx" {
  pattern = "${path.module}/lb/ingress-nginx.yaml"
  vars = {
    cert = var.zone_cert
    cidr = var.cidr_block
  }
}

data "kubectl_path_documents" "application" {
  pattern = "${path.module}/argocd/application.yaml"
  vars = {
    path                 = var.argo_path
    argo_url             = var.argo_url
    argo_admin1          = var.argo_admin1
    argo_admin2          = var.argo_admin2
    argo_admin3          = var.argo_admin3
    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
  }
}

data "kubectl_path_documents" "autoscaler" {
  pattern = "${path.module}/autoscaler/autoscaler.yaml"
  vars = {
    cluster_id   = data.aws_eks_cluster.eks.id
    iam_role_arn = data.aws_iam_role.autoscaler_isra.arn
    version      = data.aws_eks_cluster.eks.version
  }
}

data "kubectl_path_documents" "prometheus" {
  pattern = "${path.module}/prometheus/prometheus.yaml"
  vars = {
    current_account_name        = "${var.env}-${var.stage}"
    current_account_id          = data.aws_caller_identity.current.account_id
    current_account_region      = var.aws_region
    monitoring_account_id       = var.monitoring_account_id
    prometheus_remote_write_url = var.prometheus_remote_write_url
  }
}

data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "autoscaler_isra" {
  name = "cluster-autoscaler"
}