data "aws_caller_identity" "current" {}

# ***************************************
# S3
# ***************************************
resource "aws_s3_bucket" "migration_bucket" {
  bucket = "${var.env}-${var.stage}-migration-bucket"
}

resource "aws_s3_bucket_public_access_block" "private_migration_bucket" {
  bucket = aws_s3_bucket.migration_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.migration_bucket
  ]
}

resource "aws_s3_bucket_policy" "migration_bucket_bucket_policy" {
  bucket = aws_s3_bucket.migration_bucket.id
  policy = data.aws_iam_policy_document.migration_bucket_bucket_policy_rules.json

  depends_on = [
    aws_s3_bucket.migration_bucket,
    data.aws_iam_policy_document.migration_bucket_bucket_policy_rules
  ]
}

data "aws_iam_policy_document" "migration_bucket_bucket_policy_rules" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/migration-access-role"]
    }
    actions = [
      "*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.migration_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.migration_bucket.bucket}/*",
    ]
  }
}

# ***************************************
# IAM
# ***************************************
resource "aws_iam_role" "migration-access-role" {
  name        = "migration-access-role"
  description = "IAM Role relating to required migration access"

  inline_policy {
    name   = "migration-access-role-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "rds-db:connect"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${module.rds.rds_id}/migration"
          ]
        },
        {
          Action   = [
            "s3:*"
          ]
          Effect   = "Allow"
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.migration_bucket.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.migration_bucket.bucket}/*",
          ]
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:helium:rds-migration-user-access"
          }
        }
      },
    ]
  })
}