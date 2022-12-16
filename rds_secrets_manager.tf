# Generate initial random password for RDS postgres oracle_admin user
resource "random_password" "oracle_pg_admin_password" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Initialize AWS Secret Manager entry for the RDS postgres oracle_admin credentials
resource "aws_secretsmanager_secret" "oracle_pg_credentials" {
  name                     = "oracle-pg-credentials"
  description              = "Admin credentials for Oracle PostgreSQL database"
}

# Apply the RDS postgres oracle_admin credentials to the AWS Secret Manager entry
resource "aws_secretsmanager_secret_version" "oracle_pg_credentials_vals" {
  secret_id = aws_secretsmanager_secret.oracle_pg_credentials.id
  secret_string = jsonencode(
    {
      engine   = "postgres"
      host     = aws_db_instance.oracle_rds.address
      username = aws_db_instance.oracle_rds.username
      password = random_password.oracle_pg_admin_password.result
      dbname   = aws_db_instance.oracle_rds.db_name
      port     = aws_db_instance.oracle_rds.port
    }
  )
}

# Configure RDS postgres oracle_admin password rotation schedule
resource "aws_secretsmanager_secret_rotation" "rotation" {
  secret_id           = aws_secretsmanager_secret_version.oracle_pg_credentials_vals.secret_id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotator_cf_stack.outputs.RotationLambdaARN

  rotation_rules {
    automatically_after_days = 1 # Can change as needed, this is just for testing
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.database_subnets
  security_group_ids  = [aws_security_group.rds_secrets_manager_vpc_endpoint_security_group.id]
}