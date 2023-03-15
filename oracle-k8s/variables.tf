variable "env" {
  description = "Name of AWS enviroment that you're deploying to e.g., oracle, web, etc."
  type        = string
  default     = ""
}

variable "stage" {
  description = "Name of AWS stage that you're deploying to e.g., sdlc, prod"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1 for sdlc, us-west-2 for prod"
  type        = string
  default     = ""
}

variable "cidr_block" {
  description = "CIDR block for Private IP address allocation"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Route53 Zone ID"
  type        = string
  default     = ""
}

variable "argo_path" {
  description = "Path to Argo cluster manifest"
  type        = string
  default     = "argocd/manifests/cluster" // TODO: where does this path exist?
}

variable "argo_url" {
  description = "Argo URL"
  type        = string
  default     = ""
}

variable "zone_cert" {
  description = "ARN of zone certificate"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of EKS cluster for k8s deployment"
  type        = string
  default     = "oracle-cluster"
}

variable "with_autoscaler" {
  description = "Deploy cluster autoscaler"
  type        = boolean
  default     = true
}