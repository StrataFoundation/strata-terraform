# For the automated RDS posgres password rotation, we are using the AWS-provided CloudFormation stack noted below
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotator_cf_stack" {
  name             = "rds-pg-credential-rotator-stack"
  application_id   = data.aws_serverlessapplicationrepository_application.rotator.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.rotator.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.rotator.required_capabilities

  parameters = {
    endpoint            = "https://secretsmanager.${var.aws_region}.${data.aws_partition.current.dns_suffix}"
    functionName        = "rds-pg-credential-rotator"
    vpcSubnetIds        = join(",", var.database_subnet_ids)
    vpcSecurityGroupIds = "${aws_security_group.rds_secrets_manager_rotator_lambda_security_group.id},${aws_security_group.rds_access_security_group.id}"
  }
}