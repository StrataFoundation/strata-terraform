# ***************************************
# Security Group
# RDS access security group
# ***************************************
resource "aws_security_group" "public_rds_access_security_group" {
  name        = "public-rds-access-security-group"
  description = "Security group required to access Public RDS instance"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-rds-access-security-group"
  }
}

# ***************************************
# Security Group
# RDS security group
# ***************************************
resource "aws_security_group" "public_rds_security_group" {
  name        = "public-rds-security-group"
  description = "Security group for Public RDS resource"
  vpc_id      = var.vpc_id

  tags = {
    Name = "public-rds-security-group"
  }
}

# ***************************************
# Security Group Rules
# for RDS security group
# ***************************************
resource "aws_security_group_rule" "public_rds_security_group_ingress_rule_1" {
  type                     = "ingress"
  description              = "Allow access from public-rds-access-security-group"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_rds_access_security_group.id
  security_group_id        = aws_security_group.public_rds_security_group.id
}

resource "aws_security_group_rule" "public_rds_security_group_ingress_rule_2" {
  type              = "ingress"
  description       = "Allow access from Grafana" 
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["151.148.33.0/32", "151.148.33.2/32", "151.148.33.6/32"]
  security_group_id = aws_security_group.public_rds_security_group.id
}

resource "aws_security_group_rule" "public_rds_security_group_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_rds_security_group.id
}