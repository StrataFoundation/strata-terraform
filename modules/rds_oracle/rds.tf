resource "aws_db_instance" "oracle_rds" {
  count = var.deploy_cost_infrastructure ? 1 : 0

  # RDS info
  db_name                         = "oracle"
  identifier                      = "oracle-rds"
  engine                          = "postgres"
  engine_version                  = "14.5" # Latest available
  username                        = "oracle_admin"
  password                        = random_password.oracle_pg_admin_password.result
  parameter_group_name            = aws_db_parameter_group.oracle_rds_parameter_group.name
  multi_az                        = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Networking & Security
  port                                = 5432
  db_subnet_group_name                = module.vpc.database_subnet_group
  vpc_security_group_ids              = [aws_security_group.rds_security_group.id]
  iam_database_authentication_enabled = true

  # Hardware, Storage & Backup
  storage_type            = var.rds_storage_type
  allocated_storage       = var.rds_storage_size # 400GB here to get to the next threshold for IOPS (12000) and throughput (500MiB)
  max_allocated_storage   = var.rds_max_storage_size
  storage_encrypted       = true
  skip_final_snapshot     = true
  backup_retention_period = 30
  instance_class          = var.rds_instance_type
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