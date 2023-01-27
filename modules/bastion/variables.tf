variable "env" {
  description = "Name of AWS enviroment that you're deploying to e.g., oracle-prod"
  type        = string
}

variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
}

variable "aws_az" {
  description = "AWS availabilty zone you're deploying to e.g., us-east-1a"
  type        = string
}

variable "ec2_bastion_ssh_key_name" {
  description = "Name of ssh key to use to access Bastion"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID you're deploying into"
  type        = string
}

variable "user_data" {
  description = "User data to pass to Bastion during boot process"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC Bastion will be deployed into"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to apply to Bastion"
  type        = list(string)
  default     = []
}

variable "ec2_bastion_access_ips" {
  description = "The IPs, in CIDR block form (x.x.x.x/32), to whitelist access to the bastion"
  type        = list(string)
  default     = []
}

variable "cloudwatch_alarm_action_arns" {
  description = "CloudWatch Alarm Action ARNs to report CloudWatch Alarms"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type for Bastion"
  type        = string
  default     = "t3.micro"
}

variable "ec2_bastion_private_ip" {
  description = "Private IP address to assign to Bastion"
  type        = string
  default     = "10.0.1.5" # AWS reserves first 4 addresses
}

variable "volume_type" {
  description = "EBS volume type for Bastion root volume"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "EBS volume size for Bastion root volume"
  type        = string
  default     = "100"
}

variable "cloudwatch_ssh_denied_monitoring" {
  description = "Apply CloudWatch resources to monitor Bastion SSH denied access attempts. Depends on cloudwatch_alarm_action_arns var and applying CloudWatch Agent to Bastion"
  type        = bool
  default     = true
}