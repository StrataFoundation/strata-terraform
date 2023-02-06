variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "web-cluster"
}

variable "argo_path" {
  default = "argocd/manifests/cluster"
}

variable "env" {
  default = "web"
}

variable "stage" {
  default = "sdlc"
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default = "Z0569325L7XT2OOHXNLX"
}

variable "argo_url" {
  default = "argo.web.test-helium.com"
}

variable "zone_cert" {
  default = "arn:aws:acm:us-east-1:694730983297:certificate/5e357031-0723-40d3-9723-7475c6188824"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
