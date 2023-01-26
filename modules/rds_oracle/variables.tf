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