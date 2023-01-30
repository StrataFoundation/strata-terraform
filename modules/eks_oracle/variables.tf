variable "env" {
  description = "Name of AWS enviroment that you're deploying to e.g., oracle-prod"
  type        = string
}

variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
}

variable "aws_azs" {
  description = "List of AWS availabilty zone you're deploying to"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "K8s Version of EKS cluster"
  type        = string
  default     = "1.24"
}

variable "vpc_id" {
  description = "ID of VPC for EKS cluster"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block of VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for cluster deployment"
  type        = list(string)
}

variable "eks_managed_node_group_defaults" {
  description = "Configuration defaults to provide to EKS managed node group"
  type        = map
}

variable "node_security_group_tags" {
  description = "Tags to apply to node security group"
  type        = map
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "helium"
}

variable "cluster_version" {
  description = "K8s version of EKS cluster"
  type        = string
  default     = "1.24"
}

variable "cluster_node_name" {
  description = "Name of nodes in EKS cluster"
  type        = string
  default     = "small-node-group"
}

variable "cluster_min_size" {
  description = "Minimum number of nodes in EKS cluster"
  type        = number
  default     = 1
}

variable "cluster_max_size" { 
  description = "Maximum number of nodes in EKS cluster"
  type        = number
  default     = 3
}

variable "cluster_desired_size" { 
  description = "Desired number of nodes in EKS cluster"
  type        = number
  default     = 2
}

variable "manage_aws_auth_configmap" {
  description = "Manage AWS auth configmap"
  type        = bool
  default     = true
}