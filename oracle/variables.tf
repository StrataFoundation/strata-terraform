# --- Environment variables ------------------------------------------------
variable "env" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "aws_azs" {
  type = list(string)
}

variable "deploy_cost_infrastructure" {
  type = bool
}

# --- VPC variables ------------------------------------------------
variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
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

# --- EKS variables ------------------------------------------------
variable "eks_instance_type" {
  type = string
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

# --- RDS variables ------------------------------------------------
variable "rds_instance_type" {
  description = "db.m5.large | db.m6i.large"
  type = string
}

variable "rds_storage_type" {
  description = "gp3"
  type = string
}

variable "rds_storage_size" {
  description = "400"
  type = number
}

variable "rds_max_storage_size" {
  description = "1000"
  type = number
}

# --- Bastion variables ------------------------------------------------
variable "ec2_bastion_private_ip" {
  type = string
  default = "10.0.1.5" # AWS reserves first 4 addresses
}

variable "ec2_bastion_ssh_key_name" {
  type = string
}

variable "ec2_bastion_access_ips" {
  description = "The IPs, in CIDR block form (x.x.x.x/32), to whitelist access to the bastion"
  type = list(string)
}

variable "create_nova_dependent_resources" {
  description = "Should Nova-dependent resources be created"
  type = bool
}

# --- Nova IoT-specific variables ------------------------------------------------
variable "nova_iot_aws_account_id" {
  description = "The AWS account ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_iot_vpc_id" {
  description = "The VPC ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_iot_rds_access_security_group" {
  description = "The Security Group ID for the Nova IoT environment (e.g., dev or prod).\n\nIMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova IoT side."
  type = string
}

variable "nova_iot_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

# --- Nova Mobile-specific variables ------------------------------------------------
variable "nova_mobile_aws_account_id" {
  description = "The AWS account ID for the Nova Mobile environment (e.g., dev or prod).\n\nIf an empty string is provided, no Nova Mobile-dependent resources will be created"
  type = string
}

variable "nova_mobile_vpc_id" {
  description = "The VPC ID for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}

variable "nova_mobile_rds_access_security_group" {
  description = "The Security Group ID for the Nova Mobile environment (e.g., dev or prod).\n\nIMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova Mobile side."
  type = string
}

variable "nova_mobile_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}

# --- Slack ------------------------------------------------
variable "slack_webhook_url" {
  description = "Slack Webhook URL for RDS alerting."
  type = string
}