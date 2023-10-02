# ***************************************
# RDS password
# ***************************************
resource "random_password" "public_monitoring_pg_admin_password" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}


# ***************************************
# Secrets Manager
# ***************************************
resource "aws_secretsmanager_secret" "public_monitoring_pg_credentials" {
  name                     = var.stage == "sdlc" ? "public-monitoring-pg-credentials-2" : "public-monitoring-pg-credentials"
  description              = "Admin credentials for Public Monitoring PostgreSQL database"
}

# Apply the RDS postgres monitoring_admin credentials to the AWS Secret Manager entry
resource "aws_secretsmanager_secret_version" "public_monitoring_pg_credentials_vals" {
  secret_id = aws_secretsmanager_secret.public_monitoring_pg_credentials.id
  secret_string = jsonencode(
    {
      engine   = "postgres"
      host     = aws_db_instance.public_monitoring_rds.address
      username = aws_db_instance.public_monitoring_rds.username
      password = random_password.public_monitoring_pg_admin_password.result
      dbname   = aws_db_instance.public_monitoring_rds.db_name
      port     = aws_db_instance.public_monitoring_rds.port
    }
  )
}