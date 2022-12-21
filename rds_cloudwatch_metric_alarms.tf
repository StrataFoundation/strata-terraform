// CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "rds-pg-oracle-high-cpu-utilization"
  alarm_description   = "Average Oracle RDS CPU utilization is above 80%."
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

// Disk Utilization
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  alarm_name          = "rds-pg-oracle-high-disk-queue-depth"
  alarm_description   = "Average Oracle RDS disk queue depth is above 64."
  metric_name         = "DiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "64"
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space" {
  alarm_name          = "rds-pg-oracle-low-free-storage-space"
  alarm_description   = "Oracle RDS free storage space is below 10GB."
  metric_name         = "FreeStorageSpace" 
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10000000000" // 10 GB
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_iops" {
  alarm_name          = "rds-pg-oracle-high-write-iops"
  alarm_description   = "Average Oracle RDS write IOPS are above 500."
  metric_name         = "WriteIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_iops" {
  alarm_name          = "rds-pg-oracle-high-read-iops"
  alarm_description   = "Average Oracle RDS read IOPS are above 500."
  metric_name         = "ReadIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  alarm_name          = "rds-pg-oracle-high-write-throughput"
  alarm_description   = "Average Oracle RDS write throughput is above 300 MB/s."
  metric_name         = "WriteThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  alarm_name          = "rds-pg-oracle-high-read-throughput"
  alarm_description   = "Average Oracle RDS read throughput is above 300 MB/s."
  metric_name         = "ReadThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_latency" {
  alarm_name          = "rds-pg-oracle-high-write-latency"
  alarm_description   = "Average Oracle RDS write latency is above 150 ms."
  metric_name         = "WriteLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_latency" {
  alarm_name          = "rds-pg-oracle-high-read-latency"
  alarm_description   = "Average Oracle RDS read latency is above 150 ms."
  metric_name         = "ReadLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

// Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory_freeable" {
  alarm_name          = "rds-pg-oracle-low-freeable-memory"
  alarm_description   = "Average Oracle RDS freeable memory is below 256MB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage" {
  alarm_name          = "rds-pg-oracle-high-swap-usage"
  alarm_description   = "Average Oracle RDS swap usage is above 256MB."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

// Connection Count
resource "aws_cloudwatch_metric_alarm" "connection_count_anomalous" {
  alarm_name          = "rds-pg-oracle-anomalous-connection-count"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "60"
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous Oracle RDS connection count detected. Something unusual is happening."
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = "60"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.oracle_rds.id
      }
    }
  }
}

// Early Warning System for Transaction ID Wraparound
// https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/
resource "aws_cloudwatch_metric_alarm" "maximum_used_transaction_ids" {
  alarm_name          = "rds-pg-oracle-maximum-use-transaction-ids"
  alarm_description   = "Nearing a possible critical transaction ID wraparound."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MaximumUsedTransactionIDs"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1000000000" // 1 billion. Half of total.
  alarm_actions       = [module.sns_to_slack.this_slack_topic_arn]
  ok_actions          = [module.sns_to_slack.this_slack_topic_arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}