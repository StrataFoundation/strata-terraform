# Add CloudWatch log group for ssh access logs from bastion
resource "aws_cloudwatch_log_group" "bastion_ssh_denied_log_group" {
  count             = var.cloudwatch_ssh_denied_monitoring ? 1 : 0

  name              = "/aws/ec2/bastion/ssh"
  retention_in_days = 120
}

# Add CloudWatch metrics filter to ssh access logs pulled shipped from Bastion to isolate failed login attempts as a metric 
resource "aws_cloudwatch_log_metric_filter" "bastion_ssh_metrics_filter" {
  count          = var.cloudwatch_ssh_denied_monitoring ? 1 : 0

  name           = "bastion-ssh-metrics-filter"
  pattern        = "status 22"
  log_group_name = aws_cloudwatch_log_group.bastion_ssh_denied_log_group[0].name

  metric_transformation {
    name         = "ssh-denied"
    namespace    = "Bastion"
    value        = 1
  }
}

# CloudWath alert on failed login attempts to bastion
resource "aws_cloudwatch_metric_alarm" "bastion_ssh_denied_alarm" {
  count               = var.cloudwatch_ssh_denied_monitoring && length(var.cloudwatch_alarm_action_arns) < 0 ? 1 : 0

  alarm_name          = "bastion-ssh-denied"
  alarm_description   = "There was a failed login attempt to the Oracle Bastion."
  metric_name         = "ssh-denied"
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "Bastion"

  alarm_actions       = var.cloudwatch_alarm_action_arns
}