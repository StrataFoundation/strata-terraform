# ***************************************
# Security Group
# RDS access security group
# ***************************************
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


# ***************************************
# Security Group Rules
# RDS security group
# Rules are applied individually so we can deploy if VPC peering connection with isn't created.
# IMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova side.
# ***************************************
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
  description              = "Allow access from rds-secrets-manager-rotator-lambda-security-group"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_secrets_manager_rotator_lambda_security_group.id
  security_group_id        = aws_security_group.rds_security_group.id
}

resource "aws_security_group_rule" "rds_security_group_ingress_rule_3_4" {
  for_each = var.create_nova_dependent_resources ? local.nova : {}

  type                     = "ingress"
  description              = "Allow access from Nova ${each.value.label} security group" 
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = "${each.value.account_id}/${each.value.sg_id}"
  security_group_id        = aws_security_group.rds_security_group.id
}

resource "aws_security_group_rule" "rds_security_group_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_security_group.id
}

# ***************************************
# Security Group
# RDS secrets manager VPC endpoint security group
# ***************************************
resource "aws_security_group" "rds_secrets_manager_vpc_endpoint_security_group" {
  name        = "rds-secrets-manager-vpc-endpoint-security-group"
  description = "Security group required to secrets manager VPC endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.rds_secrets_manager_rotator_lambda_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-secrets-manager-vpc-endpoint-security-group"
  }
}

# ***************************************
# Security Group
# RDS secrets manager rotator lambda security group
# ***************************************
resource "aws_security_group" "rds_secrets_manager_rotator_lambda_security_group" {
  name        = "rds-secrets-manager-rotator-lambda-security-group"
  description = "Security group required to secrets manager VPC endpoint"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-secrets-manager-rotator-lambda-security-group"
  }
}