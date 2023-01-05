variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "nova_iot_aws_account_id" {
  description = "The AWS account ID for the Nova IoT environment (e.g., dev or prod)."
  type = string
}

variable "nova_mobile_aws_account_id" {
  description = "The AWS account ID for the Nova Mobile environment (e.g., dev or prod)."
  type = string
}