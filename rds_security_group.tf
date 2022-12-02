# RDS access security group
resource "aws_security_group" "rds_access_security_group" {
  name        = "rds_access_security_group"
  description = "Security group required to access RDS instance"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# RDS security group
# IMPORTANT to note terraform apply WILL FAIL on this if the VPC peering connection hasn't been accepted on the Nova side.
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "Security group for RDS resource"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow access from rds_access_security_group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_access_security_group.id]
  }

  ingress {
    description     = "Allow access from Nova security group (or cidr block)" 
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${var.nova_aws_account_id}/${var.nova_rds_access_security_group}"] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}