# IAM Role for PoCDataObjectReplicatorToS3RequesterPays lambda
resource "aws_iam_role" "iam_role_for_poc_data_object_replicator_to_S3_rp_lambda" {
  name = "PoCDataObjectReplicatorToS3RequesterPaysRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for PoCDataObjectReplicatorToS3RequesterPays for S3
resource "aws_iam_policy" "iam_s3_policy_for_poc_data_object_replicator_to_S3_rp_lambda" {
  name   = "PoCDataObjectReplicatorToS3RequesterPaysRole-s3-policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:ListBucket" // Might need more..
        ],
        Effect   = "Allow",
        Resource = concat(
          local.hf_bucket_arns_no_slash,
          local.hf_bucket_arns_with_slash
        )
      },
      {
        Action   = ["s3:PutObject"],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::${var.hf_poc_data_rp_bucket}",
          "arn:aws:s3:::${var.hf_poc_data_rp_bucket}/*"
        ]
      }
    ]
  })
}

# IAM Policy for PoCDataObjectReplicatorToS3RequesterPays for SQS
resource "aws_iam_policy" "iam_sqs_policy_for_poc_data_object_replicator_to_S3_rp_lambda" {
  name   = "PoCDataObjectReplicatorToS3RequesterPaysRole-s3-policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "sqs:SendMessage",
        ],
        Effect   = "Allow",
        Resource = "${aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.arn}"
      }
    ]
  }
  )
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  for_each = toset([
    data.aws_iam_policy.lambda_required_iam_policy.arn,
    aws_iam_policy.iam_s3_policy_for_poc_data_object_replicator_to_S3_rp_lambda.arn,
    aws_iam_policy.iam_sqs_policy_for_poc_data_object_replicator_to_S3_rp_lambda.arn
  ])

  role = aws_iam_role.iam_role_for_poc_data_object_replicator_to_S3_rp_lambda.id
  policy_arn = each.value
}