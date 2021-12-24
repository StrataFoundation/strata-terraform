resource "aws_iam_role" "cluster_instance_role" {
  description        = "cluster-instance-role-${var.env}-strata"
  assume_role_policy = file("${path.module}/policies/cluster-instance-role.json")
}

data "template_file" "cluster_instance_policy" {
  template = file("${path.module}/policies/cluster-instance-policy.json")
}

resource "aws_iam_policy" "cluster_instance_policy" {
  description = "cluster-instance-policy-${var.env}-strata"
  policy      = coalesce(var.cluster_instance_iam_policy_contents, data.template_file.cluster_instance_policy.rendered)
}

resource "aws_iam_policy_attachment" "cluster_instance_policy_attachment" {
  name       = "cluster-instance-policy-attachment-${var.env}-strata"
  roles      = [aws_iam_role.cluster_instance_role.id]
  policy_arn = aws_iam_policy.cluster_instance_policy.arn
}

resource "aws_iam_instance_profile" "cluster" {
  name = "cluster-instance-profile-${var.env}-strata"
  path = "/"
  role = aws_iam_role.cluster_instance_role.name
}

resource "aws_iam_role" "cluster_service_role" {
  description        = "cluster-service-role-${var.env}-strata"
  assume_role_policy = file("${path.module}/policies/cluster-service-role.json")

}

resource "aws_iam_policy" "cluster_service_policy" {
  description = "cluster-service-policy-${var.env}-strata"
  policy      = coalesce(var.cluster_service_iam_policy_contents, file("${path.module}/policies/cluster-service-policy.json"))
}

resource "aws_iam_policy_attachment" "cluster_service_policy_attachment" {
  name       = "cluster-instance-policy-attachment-${var.env}-strata"
  roles      = [aws_iam_role.cluster_service_role.id]
  policy_arn = aws_iam_policy.cluster_service_policy.arn
}

resource "null_resource" "iam_wait" {
  depends_on = [
    aws_iam_role.cluster_instance_role,
    aws_iam_policy.cluster_instance_policy,
    aws_iam_policy_attachment.cluster_instance_policy_attachment,
    aws_iam_instance_profile.cluster,
    aws_iam_role.cluster_service_role,
    aws_iam_policy.cluster_service_policy,
    aws_iam_policy_attachment.cluster_service_policy_attachment
  ]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}