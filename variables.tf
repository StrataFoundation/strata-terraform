variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "env" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "ovpn_users" { 
  type = list(string)
  default = ["helium"] 
}

variable "aws_azs" {
  type = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "private_subnets" {
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "instance_type" {
  default = "m5.large"
}

variable "cluster_instance_iam_policy_contents" {
  description = "The contents of the cluster instance IAM policy."
  type        = string
  default     = ""
}
variable "cluster_service_iam_policy_contents" {
  description = "The contents of the cluster service IAM policy."
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "The rotue53 zone id of the domain we're using in this tf"
  default = "Z09747452F1E9H5ZWWB5V"
}

variable "cluster_max_size" { 
  type = number
  default = 3
}

variable "vpn_count" {
  default = 1
}

variable "rds_password" {
  type = string
}

