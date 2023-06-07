# ***************************************
# PoC Data Buckets
# ***************************************

# Create PoC data buckets to receive copied/replicated objects from Nova
resource "aws_s3_bucket" "poc_data_buckets" {
  for_each = toset(local.hf_bucket_names)

  bucket = each.value
}

# Make PoC data buckets versioned
resource aws_s3_bucket_versioning version_poc_data_buckets {
  for_each = toset(local.hf_bucket_names)

  bucket = aws_s3_bucket.poc_data_buckets[each.value].id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [
    aws_s3_bucket.poc_data_buckets
  ]
}

# Publish PoC data bucket events to EventBridge
resource "aws_s3_bucket_notification" "eventbridge_enabled_poc_data_buckets" {
  for_each = toset(local.hf_bucket_names)

  bucket = aws_s3_bucket.poc_data_buckets[each.value].id
  eventbridge = true
}

# Block public access of PoC data buckets
resource "aws_s3_bucket_public_access_block" "private_poc_data_buckets" {
  for_each = toset(local.hf_bucket_names)

  bucket = aws_s3_bucket.poc_data_buckets[each.value].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.poc_data_buckets
  ]
}

# Create bucket policy for poc data buckets to enable S3 cross-account replication
resource "aws_s3_bucket_policy" "poc_data_buckets_bucket_policy_for_s3_cross_account_replication" {
  for_each = toset(local.hf_bucket_names)

  bucket = each.value
  policy = data.aws_iam_policy_document.poc_data_buckets_bucket_policy_for_s3_cross_account_replication_rules[each.value].json

  depends_on = [
    aws_s3_bucket.poc_data_buckets,
    data.aws_iam_policy_document.poc_data_buckets_bucket_policy_for_s3_cross_account_replication_rules
  ]
}

# Create bucket policy rules for bucket policies of poc data buckets to enable S3 cross-account replication from Nova
data "aws_iam_policy_document" "poc_data_buckets_bucket_policy_for_s3_cross_account_replication_rules" {
  for_each = toset(local.hf_bucket_names)
  
  statement {
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.nova_account_ids[0]}:role/foundation-s3-replication",
        "arn:aws:iam::${local.nova_account_ids[1]}:role/foundation-s3-replication"
      ]
    }
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = [
      "arn:aws:s3:::${each.value}/*",
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.nova_account_ids[0]}:root",
        "arn:aws:iam::${local.nova_account_ids[1]}:root"
      ]
    }
    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = [
      "arn:aws:s3:::${each.value}/*",
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.nova_account_ids[0]}:role/foundation-s3-replication",
        "arn:aws:iam::${local.nova_account_ids[1]}:role/foundation-s3-replication"
      ]
    }
    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]
    resources = [
      "arn:aws:s3:::${each.value}",
    ]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "poc_data_buckets_object_expiration" {
  for_each = toset(local.hf_bucket_names)

  bucket = each.value

  rule {
    id      = "all-objects"
    status  = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# ***************************************
# PoC Data Requester Pays Bucket 
# ***************************************

# Create PoC data requester pays buckets
resource "aws_s3_bucket" "poc_data_requester_pays_bucket_final" {
  bucket = var.hf_poc_data_rp_bucket
}

# Apply requester pays configuration to PoC data requester pays bucket 
resource "aws_s3_bucket_request_payment_configuration" "poc_data_bucket_requester_pays_config" {
  bucket = aws_s3_bucket.poc_data_requester_pays_bucket_final.id
  payer  = "Requester"
}

# Create bucket policy for PoC data requester pays bucket to enable requester pays
resource "aws_s3_bucket_policy" "poc_data_requester_pays_bucket_final_bucket_policy" {
  bucket = aws_s3_bucket.poc_data_requester_pays_bucket_final.id
  policy = data.aws_iam_policy_document.poc_data_requester_pays_buckets_bucket_final_policy_rules.json

  depends_on = [
    aws_s3_bucket.poc_data_requester_pays_bucket_final,
    data.aws_iam_policy_document.poc_data_requester_pays_buckets_bucket_final_policy_rules
  ]
}

# Create bucket policy rules for bucket policies of poc data bucket to enable requester pays
data "aws_iam_policy_document" "poc_data_requester_pays_buckets_bucket_final_policy_rules" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.hf_poc_data_rp_bucket}",
      "arn:aws:s3:::${var.hf_poc_data_rp_bucket}/*",
    ]
  }
}

# ***************************************
# Data Lake Requester Pays Bucket 
# ***************************************

# Create Data Lake requester pays buckets
resource "aws_s3_bucket" "data_lake_requester_pays_bucket" {
  bucket = var.hf_data_lake_rp_bucket
}

# Apply requester pays configuration to Data Lake requester pays bucket 
resource "aws_s3_bucket_request_payment_configuration" "data_lake_bucket_requester_pays_config" {
  bucket = aws_s3_bucket.data_lake_requester_pays_bucket.id
  payer  = "Requester"
}

# Create bucket policy for Data Lake requester pays bucket to enable requester pays
resource "aws_s3_bucket_policy" "data_lake_requester_pays_bucket_bucket_policy" {
  bucket = aws_s3_bucket.data_lake_requester_pays_bucket.id
  policy = data.aws_iam_policy_document.data_lake_requester_pays_buckets_bucket_policy_rules.json

  depends_on = [
    aws_s3_bucket.data_lake_requester_pays_bucket,
    data.aws_iam_policy_document.data_lake_requester_pays_buckets_bucket_policy_rules
  ]
}

# Create bucket policy rules for bucket policies of Data Lake bucket to enable requester pays
data "aws_iam_policy_document" "data_lake_requester_pays_buckets_bucket_policy_rules" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.hf_data_lake_rp_bucket}",
      "arn:aws:s3:::${var.hf_data_lake_rp_bucket}/*",
    ]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.s3_data_lake_bucket_iam_role.arn,
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.hf_data_lake_rp_bucket}/*",
    ]
  }
}

# ***************************************
# Manifest Bucket
# ***************************************

# Create manifest bucket to faciliate S3 batch operation to copy existing S3 objects from Nova 
resource "aws_s3_bucket" "mainfest_bucket" {
  bucket = local.hf_manifest_bucket_name
}

# Make manifest bucket private from public
resource "aws_s3_bucket_public_access_block" "private_mainfest_bucket" {
  bucket = aws_s3_bucket.mainfest_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.mainfest_bucket
  ]
}

# Create bucket policy for mainfest bucket to receive manifests from Nova
resource "aws_s3_bucket_policy" "s3_batch_operation_policy" {
  bucket = aws_s3_bucket.mainfest_bucket.id
  policy = data.aws_iam_policy_document.s3_batch_operation_policy_rules.json
}

# Create bucket policy rules for bucket policy of manifest bucket to faciliate S3 batch operation to copy existing S3 objects from Nova 
data "aws_iam_policy_document" "s3_batch_operation_policy_rules" {  
  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.mainfest_bucket.bucket}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${local.nova_account_ids[0]}"]
    }
  }
  
  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.mainfest_bucket.bucket}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${local.nova_account_ids[1]}"]
    }
  }
}