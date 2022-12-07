resource "aws_network_acl" "rds_db_subnet_nacl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = var.database_subnets
}

# Ingress - private subnet 1a
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_1" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_subnets[0]
  from_port      = 5432
  to_port        = 5432
}

# Ingress - private subnet 1b
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_2" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_subnets[1]
  from_port      = 5432
  to_port        = 5432
}

# Ingress - nova private subnet
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_3" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.nova_vpc_private_subnet_cidr
  from_port      = 5432
  to_port        = 5432
  count          = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}

# Egress - private subnet 1a
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_1" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_subnets[0]
  from_port      = 0
  to_port        = 65535
}

# Egress - private subnet 1b
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_2" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.private_subnets[1]
  from_port      = 0
  to_port        = 65535
}

# Egress - nova private subnet
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_3" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.nova_vpc_private_subnet_cidr
  from_port      = 0
  to_port        = 65535
  count          = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}