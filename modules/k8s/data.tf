data "kubectl_path_documents" "nginx" {
  pattern = "${path.module}/lb/ingress-nginx.yaml"
  vars = {
    cert = var.zone_cert
    cidr = var.cidr_block
  }
}

data "kubectl_path_documents" "application" {
  pattern = "${path.module}/argo/application.yaml"
  vars = {
    path = var.argo_path
  }
}

data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}
