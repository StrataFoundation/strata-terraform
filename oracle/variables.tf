# --- Environment variables ------------------------------------------------
variable "env" {
  description = "Name of AWS enviroment that you're deploying to e.g., oracle-prod"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
  default     = ""
}

variable "aws_azs" {
  description = "List of AWS availabilty zone you're deploying to"
  type        = list(string)
  default     = []
}

variable "deploy_cost_infrastructure" {
  description = "Should cost incurring infrastructure be deployed?"
  type        = bool
  default     = false
}

variable "create_nova_dependent_resources" {
  description = "Should Nova-dependent resources be created"
  type        = bool
  default     = false
}

# --- VPC variables ------------------------------------------------
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "helium"
}

variable "cidr_block" {
  description = "CIDR block for Private IP address allocation e.g., 10.0.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets from CIDR block"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets from CIDR block"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "List of database subnets from CIDR block"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

# --- EKS variables ------------------------------------------------
variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "helium"
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "K8s Version of EKS cluster"
  type        = string
  default     = "1.24"
}

variable "cluster_min_size" {
  description = "Minimum number of nodes in EKS cluster"
  type        = number
  default     = 1
}

variable "cluster_max_size" { 
  description = "Minimum number of nodes in EKS cluster"
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

# --- RDS variables ------------------------------------------------
variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "" # db.m5.large | db.m6i.large
}

variable "rds_storage_type" {
  description = "EBS storage type for RDS e.g., gp3"
  type        = string
  default     = "gp3"
}

variable "rds_storage_size" {
  description = "EBS storage size for RDS"
  type        = number
  default     = "" # 400GB here to get to the next threshold for IOPS (12000) and throughput (500MiB)
}

variable "rds_max_storage_size" {
  description = "Maximum EBS storage size for RDS"
  type        = number
  default     = "" # 1000
}

# --- Bastion variables ------------------------------------------------
variable "ec2_bastion_private_ip" {
  description = "Private IP address to assign to Bastion"
  type        = string
  default     = "10.0.1.5" # AWS reserves first 4 addresses
}

variable "ec2_bastion_ssh_key_name" {
  description = "Name of ssh key to use to access Bastion"
  type        = string
  default     = ""
}

variable "ec2_bastion_access_ips" {
  description = "The IPs, in CIDR block form (x.x.x.x/32), to whitelist access to the bastion"
  type        = list(string)
  default     = []
}

# --- Nova IoT-specific variables ------------------------------------------------
variable "nova_iot_aws_account_id" {
  description = "The AWS account ID for the Nova IoT environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

variable "nova_iot_vpc_id" {
  description = "The VPC ID for the Nova IoT environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

variable "nova_iot_rds_access_security_group" {
  description = "The Security Group ID for the Nova IoT environment (e.g., dev or prod).\n\nIMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova IoT side."
  type        = string
  default     = ""
}

variable "nova_iot_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova IoT environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

# --- Nova Mobile-specific variables ------------------------------------------------
variable "nova_mobile_aws_account_id" {
  description = "The AWS account ID for the Nova Mobile environment (e.g., dev or prod).\n\nIf an empty string is provided, no Nova Mobile-dependent resources will be created"
  type        = string
  default     = ""
}

variable "nova_mobile_vpc_id" {
  description = "The VPC ID for the Nova Mobile environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

variable "nova_mobile_rds_access_security_group" {
  description = "The Security Group ID for the Nova Mobile environment (e.g., dev or prod).\n\nIMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova Mobile side."
  type        = string
  default     = ""
}

variable "nova_mobile_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova Mobile environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

# --- Slack ------------------------------------------------
variable "slack_webhook_url" {
  description = "Slack Webhook URL for RDS alerting."
  type        = string
  default     = ""
}