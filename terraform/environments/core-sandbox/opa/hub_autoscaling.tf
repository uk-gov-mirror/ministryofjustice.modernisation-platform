##### ECS autoscaling hub ##########

resource "aws_appautoscaling_target" "hub_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "hub_scaling_policy_up" {
  name               = "${var.app_name}-scale-up-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.hub_scaling_target,
  ]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "hub_scaling_policy_down" {
  name               = "${var.app_name}-scale-down-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.hub_scaling_target,
  ]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "hub_alarm_service_cpu_high" {
  alarm_name          = "${var.app_name}-cpu-utilization-high"
  alarm_description   = "${var.aws_account} | cpu utilization high, this alarm will trigger the scale up policy."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.hub_scaling_policy_up.arn, local.monitoring_sns_topic
  ]
  ok_actions = [local.monitoring_sns_topic]

  tags = local.tags
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "hub_alarm_service_cpu_low" {
  alarm_name          = "${var.app_name}-cpu-utilization-low"
  alarm_description   = "${var.aws_account} | cpu utilization low, this alarm will trigger the scale down policy."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.hub_scaling_policy_down.arn]

  tags = local.tags
}
