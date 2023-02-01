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
  type = string
  default = "us-west-2"
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