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
  description = "Should Nova-dependent resources be created?"
  type        = bool
  default     = false
}


variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "" 
}

variable "cidr_block" {
  description = "CIDR block for Private IP address allocation e.g., 10.0.0.0/16"
  type        = string
  default     = "" # "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets from CIDR block"
  type        = list(string)
  default     = [] // ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets from CIDR block"
  type        = list(string)
  default     = [] // ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "List of database subnets from CIDR block"
  type        = list(string)
  default     = [] // ["10.0.201.0/24", "10.0.202.0/24"] 
}

variable "public_subnet_tags" {
  description = "Map of tags to apply to public subnets"
  type        = map
  default     = {}
}

variable "private_subnet_tags" {
  description = "Map of tags to apply to private subnets"
  type        = map
  default     = {}
}

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

variable "nova_iot_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova IoT environment (e.g., dev or prod)."
  type        = string
  default     = ""
}

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

variable "nova_mobile_vpc_private_subnet_cidr" {
  description = "The Private Subnet CIDR block for the Nova Mobile environment (e.g., dev or prod)."
  type        = string
  default     = ""
}