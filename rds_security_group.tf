# RDS access security group
resource "aws_security_group" "rds_access_security_group" {
  name        = "rds-access-security-group"
  description = "Security group required to access RDS instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-access-security-group"
  }
}

# RDS security group
# Rules are applied individually so we can deploy if VPC peering connection with isn't created.
# IMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova side.
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS resource"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_security_group_rule" "rds_security_group_ingress_rule_1" {
  type                     = "ingress"
  description              = "Allow access from rds-access-security-group"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_access_security_group.id
  security_group_id        = aws_security_group.rds_security_group.id
}

resource "aws_security_group_rule" "rds_security_group_ingress_rule_2" {
  type                     = "ingress"
  description              = "Allow access from Nova security group" 
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${var.nova_aws_account_id}/${var.nova_rds_access_security_group}"
  security_group_id        = aws_security_group.rds_security_group.id
  count                    = var.nova_aws_account_id == "" ? 0 : 1 # Don't create the resource if nova_aws_account_id isn't provided
}

resource "aws_security_group_rule" "rds_security_group_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_security_group.id
}