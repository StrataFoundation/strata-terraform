# ***************************************
# Database Network Access Control List (ACL)
# ***************************************
resource "aws_network_acl" "rds_db_subnet_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "db-subnets-nacl"
  }
}

# ***************************************
# Database Network ACL Rule
# Ingress - Private subnet "az a"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Ingress - Private subnet "az b"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Ingress - Databse subnet "az a"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Ingress - Databse subnet "az b"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Ingress - Bastion
# ***************************************
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_5" {
  count          = var.ec2_bastion_private_ip != "" ? 1 : 0

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.ec2_bastion_private_ip}/32"
  from_port      = 5432
  to_port        = 5432
}

# ***************************************
# Database Network ACL Rule
# Ingress - Nova IoT and Mobile private subnets
# ***************************************
resource "aws_network_acl_rule" "rds_db_subnet_nacl_ingress_6_7" {
  for_each = var.create_nova_dependent_resources ? local.nova.network : {}

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = each.value.rule_number
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = 5432
  to_port        = 5432
}

# ***************************************
# Database Network ACL Rule
# Egress - Private subnet "az a"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Egress - Private subnet "az b"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Egress - Database subnet "az a"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Egress - Database subnet "az b"
# ***************************************
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

# ***************************************
# Database Network ACL Rule
# Egress - Bastion
# ***************************************
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_5" {
  count          = var.ec2_bastion_private_ip != "" ? 1 : 0

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = 500
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.ec2_bastion_private_ip}/32"
  from_port      = 0
  to_port        = 65535
}

# ***************************************
# Database Network ACL Rule
# Egress - Nova IoT and Mobile private subnets
# ***************************************
resource "aws_network_acl_rule" "rds_db_subnet_nacl_egress_6_7" {
  for_each = var.create_nova_dependent_resources ? local.nova.network : {}

  network_acl_id = aws_network_acl.rds_db_subnet_nacl.id
  rule_number    = each.value.rule_number
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = 0
  to_port        = 65535
}