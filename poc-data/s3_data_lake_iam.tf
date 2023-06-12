resource "aws_iam_role" "s3_data_lake_bucket_iam_role" {
  name        = "s3-data-lake-bucket-access-role"
  description = "IAM role that allows access to S3 bucekt ${var.hf_data_lake_rp_bucket}"

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
            "${module.eks[0].oidc_provider}:sub" = "system:serviceaccount:helium:s3-data-lake-bucket-access"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_data_lake_bucket_iam_policy" {
  name        = "s3-data-lake-bucket-access-policy"
  description = "Policy that allows access to S3 bucket ${var.hf_data_lake_rp_bucket}"

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
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_data_lake_bucket_iam_policy_attachement" {
  role       = aws_iam_role.s3_data_lake_bucket_iam_role.name
  policy_arn = aws_iam_policy.s3_data_lake_bucket_iam_policy.arn
}