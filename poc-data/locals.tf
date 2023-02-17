locals {
  hf_bucket_names = var.hf_buckets
  hf_manifest_bucket_name = var.hf_manifest_bucket
  hf_bucket_arns_with_slash = [
    for bucket_name in var.hf_buckets : "arn:aws:s3:::${bucket_name}/*"
  ]
  hf_bucket_arns_no_slash = [
    for bucket_name in var.hf_buckets : "arn:aws:s3:::${bucket_name}"
  ]
  hf_manifest_bucket_arn = ["arn:aws:s3:::${var.hf_manifest_bucket}/*"]
  nova_account_ids = [
    "${var.nova_iot_aws_account_id}",
    "${var.nova_mobile_aws_account_id}"
  ]
  nova_bucket_names = var.nova_buckets
  nova_bucket_arns = [
    for bucket_name in var.nova_buckets : "arn:aws:s3:::${bucket_name}/*"
  ]
}