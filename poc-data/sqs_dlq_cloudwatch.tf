
resource "aws_cloudwatch_metric_alarm" "dlq_events" {
  alarm_name          = "${var.env}-${var.stage} - DLQ - Failed Events Present"
  alarm_description   = "There are failed events in the DLQ."
  metric_name         = "dlq-events"
  threshold           = 1
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = 300
  namespace           = "AWS/SQS"

  alarm_actions       = var.cloudwatch_alarm_action_arns
}