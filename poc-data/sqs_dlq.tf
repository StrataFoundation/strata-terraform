resource "aws_sqs_queue" "poc_data_object_replicator_to_S3_rp_dlq" {
  name                      = "PoCDataObjectReplicatorToS3RequesterPaysRole-DLQ"
  message_retention_seconds = 1209600 // 14 days
}

resource "aws_sqs_queue_policy" "deadletter_queue" {
  queue_url = aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.id
  policy    = data.aws_iam_policy_document.deadletter_queue.json
}

data "aws_iam_policy_document" "deadletter_queue" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.arn]
    actions = [
      "sqs:SendMessage",
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}