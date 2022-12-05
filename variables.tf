variable "aws_region" {
  type = string
  default = "us-east-1"
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

variable "aws_azs" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.201.0/24", "10.0.202.0/24"]
}

variable "instance_type" {
  default = "t3.medium"
}

variable "cluster_name" {
  type = string
  default = "helium"
}

variable "cluster_max_size" { 
  type = number
  default = 3
}

variable "cluster_desired_size" { 
  type = number
  default = 2
}

variable "rds_password" {
  type = string
}

# Nova-specific variables
variable "nova_aws_account_id" {
  description = "The AWS account ID for the Nova environment (e.g., dev or prod)."
  type = string
}

variable "nova_vpc_id" {
  description = "The VPC ID for the Nova environment (e.g., dev or prod)."
  type = string
}

variable "nova_rds_access_security_group" {
  description = "The Security Group ID for the Nova environment (e.g., dev or prod). IMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova side."
  type = string
}

variable "nova_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova environment (e.g., dev or prod)."
  type = string
}
