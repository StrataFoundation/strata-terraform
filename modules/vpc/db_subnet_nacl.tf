resource "aws_network_acl" "rds_db_subnet_nacl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "db-subnets-nacl"
  }
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

# Ingress - database subnet 1a
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_3" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.database_subnets[0]
  from_port      = 0
  to_port        = 65535
}

# Ingress - database subnet 1b
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_4" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.database_subnets[1]
  from_port      = 0
  to_port        = 65535
}

# Ingress - bastion
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_5" {
  count          = var.deploy_cost_infrastructure ? 1 : 0

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.ec2_bastion_private_ip}/32"
  from_port      = 5432
  to_port        = 5432
}

# Ingress - Nova private subnet
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_6_7" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = each.value.rule_number
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = 5432
  to_port        = 5432
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

# Egress - database subnet 1a
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_3" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.database_subnets[0]
  from_port      = 0
  to_port        = 65535
}

# Egress - database subnet 1b
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_4" {
  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.database_subnets[1]
  from_port      = 0
  to_port        = 65535
}

# Egress - bastion
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_5" {
  count          = var.deploy_cost_infrastructure ? 1 : 0

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 500
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.ec2_bastion_private_ip}/32"
  from_port      = 0
  to_port        = 65535
}

# Egress - Nova private subnet
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_6_7" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = each.value.rule_number
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = 0
  to_port        = 65535
}