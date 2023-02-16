# Create EventBridge rule for objects created in PoC data buckets
resource "aws_cloudwatch_event_rule" "poc_data_bucket_events" {
  name        = "capture-poc-data-bucket-events"
  description = "Capture object creation in PoC Data buckets"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ${local.hf_bucket_names}
    }
  }
}
EOF
}

# Create EventBridge rule for objects created in PoC data buckets
resource "aws_cloudwatch_event_target" "poc_data_bucket_events_target" {
  rule = aws_cloudwatch_event_rule.poc_data_bucket_events.name

  target_id = "PoCDataObjectReplicatorToS3RequesterPays" 
  arn       = aws_lambda_function.poc_data_object_replicator_to_S3_rp.arn 

  # Retry policy for EventBridge event delivery to the target
  retry_policy {
    maximum_retry_attempts       = 185
    maximum_event_age_in_seconds = 86400
  }

  # If EventBridge event cannot be delivered, send to DLQ
  dead_letter_config {
    arn = aws_lambda_function.poc_data_object_replicator_to_S3_rp.arn
  }
}