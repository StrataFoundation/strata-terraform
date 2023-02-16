# Create Lambda function
resource "aws_lambda_function" "poc_data_object_replicator_to_S3_rp" {
  function_name      = "PoCDataObjectReplicatorToS3RequesterPays"
  description        = "Function to copy S3 Objects from PoC Data buckets to Requester Pays buckets" 
  handler            = "index.handler"
  runtime            = "nodejs18.x"
  role               = aws_iam_role.iam_role_for_poc_data_object_replicator_to_S3_rp_lambda.arn 
  timeout            = 15

  s3_bucket          = "" // TODO
  s3_key             = "" // TODO
  source_code_hash   = data.archive_file.lambda_zip_file.output_base64sha256 // Maybe?

  environment {
    variables = {
      REGION      = var.aws_region,
      DEST_BUCKET = var.hf_poc_data_rp_bucket
    }
  }

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }
}

# data "archive_file" "lambda_zip_file" {
#   type        = "zip"
#   source_file = "${path.module}/src/app.js"
#   output_path = "${path.module}/lambda.zip"
# }

# Allow EventBridge to invoke PoCDataObjectReplicatorToS3RequesterPays Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.poc_data_object_replicator_to_S3_rp.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.poc_data_bucket_events.arn
}

# Lambda retry policy and DLQ
resource "aws_lambda_function_event_invoke_config" "retry_policy" {
  function_name = aws_lambda_function.poc_data_object_replicator_to_S3_rp.function_name

  destination_config {
    on_failure {
      destination = aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.arn
    }
  }
}