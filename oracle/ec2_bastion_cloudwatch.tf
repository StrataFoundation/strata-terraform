# Add CloudWatch log group for ssh access logs from bastion
resource "aws_cloudwatch_log_group" "bastion_ssh_denied_log_group" {
  name              = "/aws/ec2/bastion/ssh"
  retention_in_days = 120
}

# Add CloudWatch metrics filter to ssh access logs pulled shipped from Bastion to isolate failed login attempts as a metric 
resource "aws_cloudwatch_log_metric_filter" "bastion_ssh_metrics_filter" {
  name           = "bastion-ssh-metrics-filter"
  pattern        = "failed, status 22"
  log_group_name = aws_cloudwatch_log_group.bastion_ssh_denied_log_group.name

  metric_transformation {
    name         = "ssh-denied"
    namespace    = "Bastion"
    value        = 1
  }
}

# CloudWath alert on failed login attempts to bastion
resource "aws_cloudwatch_metric_alarm" "bastion_ssh_denied_alarm" {
  alarm_name          = "bastion-ssh-denied"
  metric_name         = "ssh-denied"
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "Bastion"

  alarm_actions       = [module.notify_slack.slack_topic_arn]
}