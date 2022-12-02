# RDS
resource "aws_db_instance" "oracle_rds" {
  db_name                             = "oracle"
  identifier                          = "oracle-rds"
  engine                              = "postgres"
  engine_version                      = "14.5" # Latest available
  username                            = "postgres"
  port                                = 5432
  skip_final_snapshot                 = true
  parameter_group_name                = aws_db_parameter_group.oracle_rds_parameter_group.name
  db_subnet_group_name                = module.vpc.database_subnet_group
  storage_encrypted                   = true
  vpc_security_group_ids              = [aws_security_group.rds_security_group.id]
  backup_retention_period             = 30
  iam_database_authentication_enabled = true
  multi_az                            = true

  # TODO - Need to finalize below
  allocated_storage    = 400 # Need to specificy max_allocated_storage to enable autoscaling
  instance_class       = "db.t3.micro" 
  password             = "postgres" # Create a pw in parameter store and reference here
  iops                 = 3000
  storage_type         = "io1"
  # All things monitoring ..
}

# RDS parameter group to force SSL
resource "aws_db_parameter_group" "oracle_rds_parameter_group" {
  name        = "oracle-rds-parameter-group"
  description = "Oracle RDS parameter group forcing SSL"
  family      = "postgres14"

  parameter {
    name  = "rds.force_ssl"
    value = 1
  }
}