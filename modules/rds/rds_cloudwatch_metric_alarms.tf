# ***************************************
# CloudWatch Alarm
# CPU Utilization
# ***************************************
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High CPU Utilization"
  alarm_description   = "Average Oracle RDS CPU utilization is above 80%."
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High CPU Utilization"
  alarm_description   = "Average Oracle RDS CPU utilization is above 80%."
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Disk Utilization
# ***************************************
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Disk Queue Depth"
  alarm_description   = "Average Oracle RDS disk queue depth is above 64."
  metric_name         = "DiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "64"
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Disk Queue Depth"
  alarm_description   = "Average Oracle RDS disk queue depth is above 64."
  metric_name         = "DiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "64"
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns


  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}


# ***************************************
# CloudWatch Alarm
# Disk free storage space
# ***************************************
resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space" {
  alarm_name          = "${var.env}-${var.stage} - RDS - Low Free Storage Space"
  alarm_description   = "Oracle RDS free storage space is below 10GB."
  metric_name         = "FreeStorageSpace" 
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10000000000" // 10 GB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - Low Free Storage Space"
  alarm_description   = "Oracle RDS free storage space is below 10GB."
  metric_name         = "FreeStorageSpace" 
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10000000000" // 10 GB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Disk write IOPS
# ***************************************
resource "aws_cloudwatch_metric_alarm" "write_iops" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Write IOPS"
  alarm_description   = "Average Oracle RDS write IOPS are above 500."
  metric_name         = "WriteIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_iops_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Write IOPS"
  alarm_description   = "Average Oracle RDS write IOPS are above 500."
  metric_name         = "WriteIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Disk read IOPS
# ***************************************
resource "aws_cloudwatch_metric_alarm" "read_iops" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Read IOPS"
  alarm_description   = "Average Oracle RDS read IOPS are above 500."
  metric_name         = "ReadIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_iops_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Read IOPS"
  alarm_description   = "Average Oracle RDS read IOPS are above 500."
  metric_name         = "ReadIOPS" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "500" 
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Disk write throughput
# ***************************************
resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Write Throughput"
  alarm_description   = "Average Oracle RDS write throughput is above 300 MB/s."
  metric_name         = "WriteThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throughput_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Write Throughput"
  alarm_description   = "Average Oracle RDS write throughput is above 300 MB/s."
  metric_name         = "WriteThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}


# ***************************************
# CloudWatch Alarm
# Disk read throughput
# ***************************************
resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Read Throughput"
  alarm_description   = "Average Oracle RDS read throughput is above 300 MB/s."
  metric_name         = "ReadThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_throughput_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Read Throughput"
  alarm_description   = "Average Oracle RDS read throughput is above 300 MB/s."
  metric_name         = "ReadThroughput" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "300000000" # 300MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Disk write latency
# ***************************************
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Write Latency"
  alarm_description   = "Average Oracle RDS write latency is above 150 ms."
  metric_name         = "WriteLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_latency_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Write Latency"
  alarm_description   = "Average Oracle RDS write latency is above 150 ms."
  metric_name         = "WriteLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}


# ***************************************
# CloudWatch Alarm
# Disk read latency
# ***************************************
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Read Latency"
  alarm_description   = "Average Oracle RDS read latency is above 150 ms."
  metric_name         = "ReadLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "read_latency_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Read Latency"
  alarm_description   = "Average Oracle RDS read latency is above 150 ms."
  metric_name         = "ReadLatency" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.15" // 100 ms
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Memory Utilization
# ***************************************
resource "aws_cloudwatch_metric_alarm" "memory_freeable" {
  alarm_name          = "${var.env}-${var.stage} - RDS - Low Freeable Memory"
  alarm_description   = "Average Oracle RDS freeable memory is below 256MB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_freeable_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - Low Freeable Memory"
  alarm_description   = "Average Oracle RDS freeable memory is below 256MB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Swap Utilization
# ***************************************
resource "aws_cloudwatch_metric_alarm" "memory_swap_usage" {
  alarm_name          = "${var.env}-${var.stage} - RDS - High Swap Usage"
  alarm_description   = "Average Oracle RDS swap usage is above 256MB."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - High Swap Usage"
  alarm_description   = "Average Oracle RDS swap usage is above 256MB."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}

# ***************************************
# CloudWatch Alarm
# Early Warning System for Transaction ID Wraparound
# https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/
# ***************************************
resource "aws_cloudwatch_metric_alarm" "maximum_used_transaction_ids" {
  alarm_name          = "${var.env}-${var.stage} - RDS - Max Use Transaction IDs"
  alarm_description   = "Nearing a possible critical transaction ID wraparound."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MaximumUsedTransactionIDs"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1000000000" // 1 billion. Half of total.
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds.id
  }
}

resource "aws_cloudwatch_metric_alarm" "maximum_used_transaction_ids_rr" {
  count = var.rds_read_replica ? 1 : 0

  alarm_name          = "${var.env}-${var.stage} - RDS Read Replica - Max Use Transaction IDs"
  alarm_description   = "Nearing a possible critical transaction ID wraparound."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MaximumUsedTransactionIDs"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1000000000" // 1 billion. Half of total.
  alarm_actions       = var.cloudwatch_alarm_action_arns
  ok_actions          = var.cloudwatch_alarm_action_arns

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oracle_rds_read_replica[0].id
  }
}