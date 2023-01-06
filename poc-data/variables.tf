variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "env" {
  type    = string
  default = "prod"
}


# Foundation Variables
variable "hf_buckets" {
  description = "List of Foundation buckets for cross-account S3 object replication from Nova"
  type        = list(string)
}

variable "hf_manifest_bucket" {
  description = "Name of Foundation manifest bucket"
  type        = string
}


# Nova variables
variable "nova_iot_aws_account_id" {
  description = "The AWS account ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_mobile_aws_account_id" {
  description = "The AWS account ID for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}

variable "nova_buckets" {
  description = "List of Nova buckets for cross-account S3 object replication to Foundation"
  type = list(string)
}