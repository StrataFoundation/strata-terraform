variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "env" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "aws_azs" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnets" {
  type = list(string)
  default = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "instance_type" {
  default = "m5.large"
}

variable "cluster_name" {
  type = string
  default = "helium"
}

variable "cluster_max_size" { 
  type = number
  default = 3
}

variable "cluster_desired_size" { 
  type = number
  default = 2
}

variable "rds_password" {
  type = string
}

variable "external_dns_chart_log_level" {
  description = "External-dns Helm chart log leve. Possible values are: panic, debug, info, warn, error, fatal"
  type        = string
  default     = "warn"
}

variable "external_dns_zoneType" {
  description = "External-dns Helm chart AWS DNS zone type (public, private or empty for both)"
  type        = string
  default     = ""
}

variable "external_dns_domain_filters" {
  description = "External-dns Domain filters."
  type        = list(string)
  default = ["test-helium.com"]
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default = "Z050039512T5DB5GPPHRV"
}

variable "argo_url" {
  default = "argo.oracle.test-helium.com"
}

variable "zone_cert" {
  default = "arn:aws:acm:us-east-1:848739503602:certificate/c9616061-04ef-48a3-91fa-0fc62fcab6df"
}

variable "domain_filter" {
  description = "External-dns Domain filter."
  type       = string
  default = "oracle.test-helium.com"
}
