
resource "aws_cloudwatch_metric_alarm" "dlq_events" {
  alarm_name          = "${var.env}-${var.stage} - ${aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.name} - Failed Events Present"
  alarm_description   = "There are failed events in the DLQ."
  metric_name         = "ApproximateNumberOfMessagesVisible"
  threshold           = 1
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = 300
  namespace           = "AWS/SQS"
  alarm_actions       = [module.notify_slack.slack_topic_arn]

  dimensions = {
    QueueName = aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.name
  }
}