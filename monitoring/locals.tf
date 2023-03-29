locals {
  iam_roles_receiving_write_permission_to_amp = [
    for account_id in var.account_ids : "arn:aws:iam::${account_id}:role/EKS-AMP-ServiceAccount-Role"
  ]
}