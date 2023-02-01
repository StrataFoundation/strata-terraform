locals {
  nova = {
    iot = {
      label = "IoT",
      account_id = var.nova_iot_aws_account_id,
      vpc_id = var.nova_iot_vpc_id,
      cidr = var.nova_iot_vpc_private_subnet_cidr,
    }
    mobile = { 
      label = "Mobile",
      account_id = var.nova_mobile_aws_account_id,
      vpc_id = var.nova_mobile_vpc_id,
      cidr = var.nova_mobile_vpc_private_subnet_cidr,
    }
  }
}