# ***************************************
# Environment variables
# ***************************************
variable "env" {
  type = string
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
# RDS variables
# ***************************************
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

variable "database_subnet_group" {
  type = string
}

variable "database_subnets" {
  type = string
}

# ***************************************
# IAM variables
# ***************************************
variable "oidc_provider" {
  type = string
}
variable "oidc_provider_arn" {
  type = string
}


# ***************************************
# NACL variables
# ***************************************
variable "private_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.201.0/24", "10.0.202.0/24"]
}