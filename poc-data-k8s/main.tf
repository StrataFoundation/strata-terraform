provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform = "true"
      Environment = var.env
    }
  }
}

# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

module "k8s" {
  source = "../modules/k8s"

  # Env
  env   = var.env 
  stage = var.stage 
  cluster_name = var.cluster_name 

  # AWS
  aws_region = var.aws_region

  # VPC
  cidr_block = var.cidr_block

  # K8s - Argo
  argo_path            = var.argo_path
  argo_admin1          = var.argo_admin1
  argo_admin2          = var.argo_admin2
  argo_admin3          = var.argo_admin3
  argo_admin4          = var.argo_admin4
  argo_admin5          = var.argo_admin5
  argo_admin6          = var.argo_admin6
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  zone_id              = var.zone_id 
  argo_url             = var.argo_url
  zone_cert            = var.zone_cert

  # K8s -Autoscaling
  with_autoscaler = var.with_autoscaler

  # K8s - Monitoring
  with_central_monitoring     = var.with_central_monitoring
  monitoring_account_id       = var.monitoring_account_id
  monitoring_account_region   = var.monitoring_account_region
  prometheus_remote_write_url = var.prometheus_remote_write_url
}

data "aws_iam_role" "s3_data_lake_bucket_access_role" {
  name = "s3-data-lake-bucket-access-role" 
}

data "aws_iam_role" "spark_data_lake_access_role" {
  name = "spark-data-lake-access-role" 
}

resource "kubernetes_service_account" "s3_data_lake_bucket_access" {
  metadata {
    name        = "s3-data-lake-bucket-access"
    namespace   = "helium"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.s3_data_lake_bucket_access_role.arn,
    }
  }
}

resource "kubernetes_service_account" "spark_data_lake_access" {
  metadata {
    name        = "spark-data-lake-access"
    namespace   = "spark"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.spark_data_lake_access_role.arn,
    }
  }
}

resource "kubernetes_role_binding" "spark_data_lake_access_rb" {
  metadata {
    name      = "spakr-data-lake-access-rb"
    namespace = "spark"
  }

  role_ref {
    kind     = "Role"
    name     = "spark-role"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.spark_data_lake_access.metadata[0].name
    namespace = kubernetes_service_account.spark_data_lake_access.metadata[0].namespace
  }
}

resource "helm_release" "jupyterhub" {
  name  = "jupyterhub"

  repository       = "https://jupyterhub.github.io/helm-chart"
  chart            = "jupyterhub"
  namespace        = "spark"
  version          = "2.0.0"
  create_namespace = true

  set {
    name = "singleuser.image.name"
    value = "jupyter/all-spark-notebook"
  }

  set {
    name = "singleuser.image.tag"
    value = "latest"
  }

  set {
    name = "hub.config.GoogleOAuthenticator.client_id"
    value = var.jupyter_google_client_id
  }

  set {
    name = "hub.config.GoogleOAuthenticator.client_secret"
    value = var.jupyter_google_client_secret
  }

  set {
    name = "hub.config.GoogleOAuthenticator.oauth_callback_url"
    value = "https://${var.jupyter_uri}"
  }

  set_list {
    name = "hub.config.GoogleOAuthenticator.hosted_domain"
    value = ["${var.jupyter_uri}"]
  }

  set {
    name = "hub.config.GoogleOAuthenticator.login_service"
    value = "Helium Inc"
  }

  set {
    name = "hub.config.GoogleOAuthenticator.JupyterHub.authenticator_class"
    value = "google"
  }

  set {
    name = "ingress.enabled"
    value = "true"
  }

  set_list {
    name = "ingress.hosts"
    value = ["${var.jupyter_uri}"]
  }
}

resource "helm_release" "spark_on_k8s" {
  name  = "spark-operator"

  repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart            = "spark-operator"
  namespace        = "spark"
  version          = "1.1.27"
  create_namespace = true

  set {
    name = "webhook.enable"
    value = true
  }

  set {
    name = "webhook.port"
    value = 443
  }
}
