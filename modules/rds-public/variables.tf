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
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of VPC for RDS security group"
  type        = string
  default     = ""
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
  default     = ""
}

variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = ""
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "" # 14.5 Latest available
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
}

variable "db_multi_az" {
  description = "Multi-az deployment"
  type        = bool
  default     = false
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

variable "public_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
  default     = []
}

variable "oidc_provider" {
  description = "EKS OIDC provider name to enable K8s pods to assume IAM role to access RDS"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider arn to enable K8s pods to assume IAM role to access RDS"
  type        = string
  default     = ""
}

variable "deploy_from_snapshot" {
  description = "Deploy RDS from snapshot"
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "Snapshot identifier for restoration e.g., rds:production-2015-06-26-06-05"
  type        = string
  default     = ""
}