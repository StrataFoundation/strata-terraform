output "rds_access_security_group_id" {
  value = aws_security_group.rds_access_security_group.id
}

output "rds_id" {
  value = aws_db_instance.oracle_rds.resource_id
}