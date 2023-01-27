variable "env" {
  description = "Name of AWS enviroment that you're deploying to e.g., oracle-prod"
  type        = string
}

variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
}

variable "create_nova_dependent_resources" {
  description = "Should Nova-dependent resources be created"
  type        = bool
}

variable "db_subnet_group_name" {
  description = "Name of database subnet group"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC for RDS security group"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group ids to apply to RDS"
  type        = list(string)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = true
}

variable "ssl_required" {
  description = "Require SSL to connect to database. Engine must be Postgres"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "oracle"
}

variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "oracle-rds"
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "14.5" # Latest available
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "oracle_admin"
}

variable "db_multi_az" {
  description = "Multi-az deployment"
  type        = bool
  default     = true
}

variable "db_log_exports" {
  description = "Enable CloudWatch log exports"
  type        = list(string)
  default     = ["postgresql"]
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}


variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "db.m6i.large"
}

variable "rds_storage_type" {
  description = "EBS storage type for RDS e.g., gp3"
  type        = string
  default     = "gp3"
}

variable "rds_storage_size" {
  description = "EBS storage size for RDS"
  type        = number
  default     = 400 # 400GB here to get to the next threshold for IOPS (12000) and throughput (500MiB)
}

variable "rds_max_storage_size" {
  description = "Maximum EBS storage size for RDS"
  type        = number
  default     = 1000
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
}

variable "oidc_provider" {
  description = "EKS OIDC provider name to enable K8s pods to assume IAM role to access RDS"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider arn to enable K8s pods to assume IAM role to access RDS"
  type        = string
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

variable "ec2_bastion_private_ip" {
  description = "Private IP address of Bastion"
  type        = string
}

variable "cloudwatch_alarm_action_arns" {
  description = "CloudWatch Alarm Action ARNs to report CloudWatch Alarms"
  type        = list(string)
  default     = []
}