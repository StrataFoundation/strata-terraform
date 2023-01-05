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

  inline_policy {
    name = "foundation-batch-operations-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "batchoperations.s3.amazonaws.com"
          }
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
          Resource = [
            "arn:aws:s3:::foundation-entropy/*",
            "arn:aws:s3:::foundation-iot-ingest/*",
            "arn:aws:s3:::foundation-iot-packet-ingest/*",
            "arn:aws:s3:::foundation-iot-packet-verifier/*",
            "arn:aws:s3:::foundation-iot-verifier/*",
            "arn:aws:s3:::foundation-mobile-ingest/*",
            "arn:aws:s3:::foundation-mobile-packet-ingest/*",
            "arn:aws:s3:::foundation-mobile-packet-verifier/*",
            "arn:aws:s3:::foundation-mobile-verifier/*",
            "arn:aws:s3:::mainnet-iot-entropy/*",
            "arn:aws:s3:::mainnet-iot-ingest/*",
            "arn:aws:s3:::mainnet-iot-packet-reports/*",
            "arn:aws:s3:::mainnet-iot-reports/*",
            "arn:aws:s3:::mainnet-iot-rewards/*",
            "arn:aws:s3:::mainnet-iot-verified-rewards/*",
            "arn:aws:s3:::${aws_s3_bucket.mainfest_bucket.bucket}/*"
          ]
        }
      ]
    })
  }
}