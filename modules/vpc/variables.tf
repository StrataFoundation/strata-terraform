# ***************************************
# Environment variables
# ***************************************
variable "env" {
  type = string
}
variable "deploy_cost_infrastructure" {
  type = bool
}

variable "create_nova_dependent_resources" {
  description = "Should Nova-dependent resources be created"
  type = bool
}

# ***************************************
# AWS variables
# ***************************************

variable "aws_region" {
  type = string
}

variable "aws_azs" {
  type = list(string)
}

# ***************************************
# VPC variables
# ***************************************
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

# ***************************************
# Nova IoT-specific variables 
# ***************************************
variable "nova_iot_aws_account_id" {
  description = "The AWS account ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_iot_vpc_id" {
  description = "The VPC ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_iot_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

# ***************************************
# Nova Mobile-specific variables 
# ***************************************
variable "nova_mobile_aws_account_id" {
  description = "The AWS account ID for the Nova Mobile environment (e.g., dev or prod).\n\nIf an empty string is provided, no Nova Mobile-dependent resources will be created"
  type = string
}

variable "nova_mobile_vpc_id" {
  description = "The VPC ID for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}

variable "nova_mobile_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}