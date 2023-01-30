# ***************************************
# VPC
# ***************************************
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # Basic VPC details
  name = var.vpc_name
  cidr = var.cidr_block
  azs  = var.aws_azs

  # Public subnets
  public_subnets     = var.public_subnets
  public_subnet_tags = var.public_subnet_tags
  
  # Private subnets
  private_subnets     = var.private_subnets
  private_subnet_tags = var.private_subnet_tags

  # Database subnets
  database_subnets                   = length(var.database_subnets) > 0 ? var.database_subnets : null
  create_database_subnet_group       = length(var.database_subnets) > 0 ? true : false
  create_database_subnet_route_table = length(var.database_subnets) > 0 ? true : false

  # NAT gateway 
  enable_nat_gateway     = var.deploy_cost_infrastructure ? true : false
  one_nat_gateway_per_az = var.deploy_cost_infrastructure ? true : false  # Each availability zone will get a NAT gateway, done so for high availability
  single_nat_gateway     = false

  # VPN gateway
  enable_vpn_gateway = true # Not sure if we need this

  # DNS parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow logs to S3 bucket in Log Archive Account
  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = "arn:aws:s3:::vpc-flow-logs-${data.aws_caller_identity.current.account_id}"
}

# ***************************************
# VPC Peering Connections
# Create connections with specified Nova IoT and Mobile AWS accounts
# ***************************************
resource "aws_vpc_peering_connection" "nova_vpc_peering_connection" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = each.value.vpc_id
  peer_owner_id = each.value.account_id

  tags = {
    Name = "VPC Peering to Nova ${each.value.label}"
  }
}

# ***************************************
# Database Route Table Updates
# Add route "az a" route table allowing connection to specified private Nova IoT and Mobile subnets via VPC peering connection
# ***************************************
resource "aws_route" "database_route_table_route_to_nova_az_a" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  route_table_id            = module.vpc.database_route_table_ids[0]
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.nova_vpc_peering_connection[each.key].id
}

# ***************************************
# Database Route Table Updates
# Add route "az b" route table allowing connection to specified private Nova IoT and Mobile subnets via VPC peering connection
# ***************************************
resource "aws_route" "database_route_table_route_to_nova_az_b" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  route_table_id            = module.vpc.database_route_table_ids[1]
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.nova_vpc_peering_connection[each.key].id
}