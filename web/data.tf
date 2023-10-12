data "aws_lb" "lb" {
  name = var.lb_name
}

data "aws_iam_policy" "public_monitoring_rds_access_policy" {
  name = "public-monitoring-rds-access-policy"

  depends_on = [ module.rds_public ]
}