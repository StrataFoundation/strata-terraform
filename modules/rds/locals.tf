locals {
  nova = {

    users = {
      iot = {
        label = "IoT",
        user = "nova_iot",
        account_id = var.nova_iot_aws_account_id,
      }
      iot-meta = {
        label = "IoT",
        user = "nova_iot_meta",
        account_id = var.nova_iot_aws_account_id,
      }
      mobile = {
        label = "Mobile",
        user = "nova_mobile",
        account_id = var.nova_mobile_aws_account_id,       
      }
      mobile-meta = {
        label = "Mobile",
        user = "nova_mobile_meta",
        account_id = var.nova_mobile_aws_account_id,      
      }
    }
    network = {
      iot = {
        label = "IoT",
        account_id = var.nova_iot_aws_account_id,
        vpc_id = var.nova_iot_vpc_id,
        sg_id = var.nova_iot_rds_access_security_group,
        cidr = var.nova_iot_vpc_private_subnet_cidr,
        rule_number = 600
      }
      mobile = { 
        label = "Mobile",
        account_id = var.nova_mobile_aws_account_id,
        vpc_id = var.nova_mobile_vpc_id,
        sg_id = var.nova_mobile_rds_access_security_group,
        cidr = var.nova_mobile_vpc_private_subnet_cidr,
        rule_number = 700
      }
    }
  }
  foundation = {
    oracle = {
      mobile = { 
        user = "mobile_oracle"
        iam_name = "rds-mobile-oracle-user-access"
      }
      iot = {
        user = "iot_oracle"
        iam_name = "rds-iot-oracle-user-access"
      }
    }
    web = {
      web = { 
        user = "web"
        iam_name = "rds-web-user-access"
      }
    }
  }
}