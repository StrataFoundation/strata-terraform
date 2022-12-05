module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # Basic VPC details
  name = var.vpc_name
  cidr = var.cidr_block
  azs  = var.aws_azs

  # Public subnets
  public_subnets     = var.public_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  # Private subnets
  private_subnets     = var.private_subnets
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  # Database subnets
  database_subnets                   = var.database_subnets
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  # NAT gateway 
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true # Each availability zone will get a NAT gateway, done so for high availability
  
  # VPN gateway
  enable_vpn_gateway = true # Not sure if we need this

  # DNS parameters
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create VPC Peering connection with specified Nova AWS account
resource "aws_vpc_peering_connection" "nova_vpc_peering_connection" {
  vpc_id        = module.vpc.vpc_id
  peer_vpc_id   = var.nova_vpc_id
  peer_owner_id = var.nova_aws_account_id
  count         = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}

# Add route to database us-east-1a route table allowing connection to specified private Nova subnet via VPC peering connection
resource "aws_route" "database_route_table_route_to_nova_az_1a" {
  route_table_id            = module.vpc.database_route_table_ids[0]
  destination_cidr_block    = var.nova_vpc_private_subnet_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.nova_vpc_peering_connection[0].id
  count                     = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}

# Add route to database us-east-1b route table allowing connection to specified private Nova subnet via VPC peering connection
resource "aws_route" "database_route_table_route_to_nova_az_1b" {
  route_table_id            = module.vpc.database_route_table_ids[1]
  destination_cidr_block    = var.nova_vpc_private_subnet_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.nova_vpc_peering_connection[0].id
  count                     = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}