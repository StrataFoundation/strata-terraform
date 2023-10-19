output "public_rds_access_security_group_id" {
  value = aws_security_group.public_rds_access_security_group.id
}

output "public_monitoring_rds_read_replica_access_policy_arn" {
  value = var.rds_public_read_replica ? aws_iam_policy.public_monitoring_rds_read_replica_access_policy.arn : null
}