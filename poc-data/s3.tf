# Create PoC data buckets to receive copied/replicated objects from Nova
resource "aws_s3_bucket" "poc_data_buckets" {
  for_each = toset(local.hf_bucket_names)

  bucket = each.value
}

resource aws_s3_bucket_versioning version_poc_data_buckets {
  for_each = toset(local.hf_bucket_names)

  bucket = aws_s3_bucket.poc_data_buckets[each.value].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create manifest bucket to faciliate S3 batch operation to copy existing S3 objects from Nova 
resource "aws_s3_bucket" "mainfest_bucket" {
  bucket = "nova-s3-object-manifests"
}

# Create bucket policy for poc data buckets to enable S3 cross-account replication
resource "aws_s3_bucket_policy" "poc_data_buckets_bucket_policy_for_s3_cross_account_replication" {
  for_each = toset(local.hf_bucket_names)

  bucket = each.value
  policy = data.aws_iam_policy_document.poc_data_buckets_bucket_policy_for_s3_cross_account_replication_rules[each.value].json
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

# Create bucket policy for mainfest bucket to receive manifests from Nova
resource "aws_s3_bucket_policy" "s3_batch_operation_policy" {
  bucket = aws_s3_bucket.mainfest_bucket.bucket
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