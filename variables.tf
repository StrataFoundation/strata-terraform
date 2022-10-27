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

variable "zone_ids" {
  description = "The rotue53 zone ids of the domains accessible to k8s"
  default = ["Z00702383HA5R7HK4JVO3"]
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

