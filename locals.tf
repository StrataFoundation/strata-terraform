locals {
  cluster_name = "${var.cluster_name}-${var.env}"
}

#  vpc.tf, rds_security_group.tf, rds_user_iam.tf, rds_db_subnet_nacl.tf
locals {
  nova = {
    iot = {
      label = "IoT",
      user = "nova_iot",
      account_id = var.nova_iot_aws_account_id,
      vpc_id = var.nova_iot_vpc_id,
      sg_id = var.nova_iot_rds_access_security_group,
      cidr = var.nova_iot_vpc_private_subnet_cidr,
      rule_number = 600
    }
    mobile = { 
      label = "Mobile",
      user = "nova_mobile",
      account_id = var.nova_mobile_aws_account_id,
      vpc_id = var.nova_mobile_vpc_id,
      sg_id = var.nova_mobile_rds_access_security_group,
      cidr = var.nova_mobile_vpc_private_subnet_cidr,
      rule_number = 700
    }
  }
  foundation = {
    active-device = { 
      user = "active_device_oracle"
    }
    mobile = { 
      user = "mobile_oracle"
    }
  }
}