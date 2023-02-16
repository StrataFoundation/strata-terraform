# CloudWatch Log Group for PoCDataObjectReplicatorToS3RequesterPays lambda
resource "aws_cloudwatch_log_group" "poc_data_object_replicator_to_S3_rp_lambda_group" {
  name              = "/aws/lambda/${aws_lambda_function.poc_data_object_replicator_to_S3_rp.function_name}"
  retention_in_days = 30
  lifecycle {
    prevent_destroy = false
  }
}