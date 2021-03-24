# RDS alarms
resource "aws_cloudwatch_metric_alarm" "RDS_CPU_over_threshold" {
  alarm_name          = "${var.app_name}-RDS-CPU-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS CPU is above 75% please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "75"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags

}

resource "aws_cloudwatch_metric_alarm" "RDS_Disk_Queue_Depth_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-DiskQueue-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS disk queue is above 4, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "DiskQueueDepth"
  statistic           = "Average"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "4"
  treat_missing_data  = "notBreaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "RDS_Free_Storage_Space_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-FreeStorageSpace-low-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Free storage space is below 50 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "50"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags

}

resource "aws_cloudwatch_metric_alarm" "RDS_Read_Lataency_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-ReadLatency-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Read Latency is above 0.5 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "ReadLatency"
  statistic           = "Average"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "0.5"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags

}

resource "aws_cloudwatch_metric_alarm" "RDS_Write_Latency_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-WriteLatency-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS write latency is above 0.5 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "WriteLatency"
  statistic           = "Average"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "0.5"
  treat_missing_data  = "notBreaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "RDS_Swap_Usage_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-SwapUsage-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS swap usage is above 0.5GB please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "SwapUsage"
  statistic           = "Sum"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "500000000"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "RDS_Freeable_Memory_Over_Threshold" {
  alarm_name          = "${var.app_name}-RDS-FreeableMemory-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Freeable Memory is above 500MB please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "LessThanThreshold"
  metric_name         = "FreeableMemory"
  statistic           = "Sum"
  namespace           = "AWS/RDS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "500"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "RDS_Burst_Balance_Threshold" {
  alarm_name          = "${var.app_name}-RDS-BurstBalance-low-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Burst balance is below 1 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "BurstBalance"
  statistic           = "Sum"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "5"
  threshold           = "1"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "RDS_Write_IOPS_Threshold" {
  alarm_name          = "${var.app_name}-RDS-WriteIOPS-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Write IOPS is above 300 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "WriteIOPS"
  statistic           = "Sum"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "3"
  threshold           = "300"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "RDS_Read_IOPS_Threshold" {
  alarm_name          = "${var.app_name}-RDS-ReadIOPS-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | RDS Read IOPS is above 300 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "ReadIOPS"
  statistic           = "Sum"
  namespace           = "AWS/RDS"
  period              = "300"
  evaluation_periods  = "3"
  threshold           = "300"
  treat_missing_data  = "breaching"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.opa18-hub-db.id
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_db_event_subscription" "rds_events" {
  name      = "${var.app_name}-rds-event-sub"
  sns_topic = local.monitoring_sns_topic

  source_type = "db-instance"
  source_ids  = [aws_db_instance.opa18-hub-db.id]

  event_categories = [
    "availability",
    "configuration change",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "recovery",
    "restoration",
  ]

  tags = local.tags
}

# ECS Alerts
# See autoscaling files for CPU alerts
resource "aws_cloudwatch_metric_alarm" "Hub_Ecs_Memory_Over_Threshold" {
  alarm_name          = "${var.app_name}-ECS-Memory-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | OPA Hub ECS average memory usage is above 75% please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  namespace           = "AWS/ECS"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "75"
  treat_missing_data  = "breaching"
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}


# EC2 / Autoscaling group alarms
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_over_Threshold" {
  alarm_name          = "${var.app_name}-EC2-CPU-high-threshold-alarm"
  alarm_description   = "${var.aws_account} | OPA Cluster EC2 CPU utilisation is above 85% please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/EC2"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "85"
  treat_missing_data  = "breaching"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cluster-scaling-group.name
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Status_Check_Failure" {
  alarm_name          = "${var.app_name}-status-check-failure-alarm"
  alarm_description   = "${var.aws_account} | An OPA HUB cluster EC2 instance has failed a status check, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "StatusCheckFailed"
  statistic           = "Average"
  namespace           = "AWS/EC2"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "1"
  treat_missing_data  = "breaching"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cluster-scaling-group.name
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

# Application load balancer alerts HUB
resource "aws_cloudwatch_metric_alarm" "Hub_Target_Response_Time" {
  alarm_name          = "${var.app_name}-alb-target-response-time-alarm"
  alarm_description   = "${var.aws_account} | Target response time average for the hub target group is above 1 please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "TargetResponseTime"
  extended_statistic  = "p99"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "3"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_Target_Response_Time_Maximum" {
  alarm_name          = "${var.app_name}-alb-target-response-time-alarm-maximum"
  alarm_description   = "${var.aws_account} | Target response time for the hub target group is above 60 seconds, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "TargetResponseTime"
  statistic           = "Maximum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "1"
  threshold           = "60"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_UnHealthy_Hosts" {
  alarm_name          = "${var.app_name}-unhealthy-hosts-alarm"
  alarm_description   = "${var.aws_account} | There is an unhealthy host in the hub target group for over 15min, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Average"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "0"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
    TargetGroup  = aws_lb_target_group.target_group.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_Rejected_Connection_Count" {
  alarm_name          = "${var.app_name}-RejectedConnectionCount-alarm"
  alarm_description   = "${var.aws_account} | The HUB ALB has rejected over 10 requests, usually due to backend being busy, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "RejectedConnectionCount"
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "10"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_http5xxError" {
  alarm_name          = "${var.app_name}-http-5xx-error-alarm"
  alarm_description   = "${var.aws_account} | Hub ALB - 4 5XX http alerts in a 5 minute period, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "10"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_ApplicationELB5xxError" {
  alarm_name          = "${var.app_name}-elb-5xx-error-alarm"
  alarm_description   = "${var.aws_account} | HUB ALB - 4 5XX elb alerts in a 5 minute period, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "10"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_http4xxError" {
  alarm_name          = "${var.app_name}-http-4xx-error-alarm"
  alarm_description   = "${var.aws_account} | HUB ALB - 4 4XX http alerts in a 5 minute period, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_Target_4XX_Count"
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "10"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "Hub_ApplicationELB4xxError" {
  alarm_name          = "${var.app_name}-elb-4xx-error-alarm"
  alarm_description   = "${var.aws_account} | HUB ALB - 4 4XX elb alerts in a 5 minute period, please investigate, runbook - https://dsdmoj.atlassian.net/wiki/spaces/CCMS/pages/1408598133/Monitoring+and+Alerts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  evaluation_periods  = "5"
  threshold           = "10"
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.load_balancer.arn_suffix
  }

  alarm_actions = [local.monitoring_sns_topic]
  ok_actions    = [local.monitoring_sns_topic]

  tags = local.tags
}
