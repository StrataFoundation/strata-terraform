# IAM role for S3 Batch Operation to perform cross-account object copy from Nova
resource "aws_iam_role" "foundation_batch_operations_role" {
  name = "foundation-batch-operations-role"

  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Principal = {
              Service = "batchoperations.s3.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_policy" "foundation_batch_operations_policy" {
  name        = "foundation-batch-operations-policy"
  description = "Policy to allow S3 Batch Opertion to operate with Nova AWS Accounts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectVersionAcl",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionTagging",
          "s3:PutObjectTagging",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = concat(
          local.hf_bucket_arns_with_slash,
          local.hf_manifest_bucket_arn,
          local.nova_bucket_arns
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "foundation_batch_operations_policy_attachement" {
  role       = aws_iam_role.foundation_batch_operations_role.name
  policy_arn = aws_iam_policy.foundation_batch_operations_policy.arn
}