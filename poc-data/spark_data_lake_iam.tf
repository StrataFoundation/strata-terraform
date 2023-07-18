resource "aws_iam_role" "spark_data_lake_iam_role" {
  name        = "spark-data-lake-access-role"
  description = "IAM role that allows access to S3 buckets ${var.hf_data_lake_rp_bucket} and ${var.hf_data_lake_dev_bucket}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks[0].oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${module.eks[0].oidc_provider}:sub" = "system:serviceaccount:spark:spark-data-lake-access"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "spark_data_lake_iam_policy" {
  name        = "spark-data-lake-access-policy"
  description = "Policy that allows access to S3 buckets ${var.hf_data_lake_rp_bucket} and ${var.hf_data_lake_dev_bucket}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${var.hf_data_lake_rp_bucket}",
          "arn:aws:s3:::${var.hf_data_lake_rp_bucket}/*",
          "arn:aws:s3:::${var.hf_data_lake_dev_bucket}",
          "arn:aws:s3:::${var.hf_data_lake_dev_bucket}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "spark_data_lake_iam_policy_attachement" {
  role       = aws_iam_role.spark_data_lake_iam_role.name
  policy_arn = aws_iam_policy.spark_data_lake_iam_policy.arn
}