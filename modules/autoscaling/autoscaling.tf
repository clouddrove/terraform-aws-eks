locals {
  autoscaling_enabled               = var.enabled && var.ondemand_enabled ? true : false
  spot_autoscaling_enabled          = var.enabled && var.spot_enabled ? true : false
  autoscaling_enabled_schedule      = var.enabled && var.ondemand_enabled && var.schedule_enabled ? true : false
  autoscaling_enabled_spot_schedule = var.enabled && var.spot_enabled && var.spot_schedule_enabled ? true : false
}

#Module      : AUTOSCALING POLICY UP
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_up" {
  count                  = local.autoscaling_enabled ? length(var.ondemand_instance_type) : 0
  name                   = format("%s%sscale%sup", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = element(aws_autoscaling_group.on_demand.*.name, count.index)

}
#Module      : AUTOSCALING POLICY UP
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_up_spot" {
  count                  = local.spot_autoscaling_enabled ? length(var.spot_instance_type) : 0
  name                   = format("%s%sscale%sup-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = element(aws_autoscaling_group.spot.*.name, count.index)

}

#Module      : AUTOSCALING POLICY DOWN
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_down" {
  count                  = local.autoscaling_enabled ? length(var.ondemand_instance_type) : 0
  name                   = format("%s%sscale%sdown", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = element(aws_autoscaling_group.on_demand.*.name, count.index)
}

#Module      : AUTOSCALING POLICY DOWN
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_down_spot" {
  count                  = local.spot_autoscaling_enabled ? length(var.spot_instance_type) : 0
  name                   = format("%s%sscale%sdown-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = element(aws_autoscaling_group.spot.*.name, count.index)
}

#Module      : AWS AUTOSCALING SCHEDULE
#Description : Provides an AutoScaling Schedule resource.
resource "aws_autoscaling_schedule" "scaledown" {
  count                  = local.autoscaling_enabled_schedule ? length(var.ondemand_instance_type) : 0
  autoscaling_group_name = element(aws_autoscaling_group.on_demand.*.name, count.index)
  scheduled_action_name  = format("%s-scheduler-down", module.labels.id)
  min_size               = element(var.schedule_min_size_scaledown, count.index)
  max_size               = element(var.schedule_max_size_scaledown, count.index)
  desired_capacity       = element(var.schedule_desired_scale_down, count.index)
  recurrence             = var.scheduler_down
}

#Module      : AWS AUTOSCALING SCHEDULE
#Description : Provides an AutoScaling Schedule resource.
resource "aws_autoscaling_schedule" "spot_scaledown" {
  count                  = local.autoscaling_enabled_spot_schedule ? length(var.spot_instance_type) : 0
  autoscaling_group_name = element(aws_autoscaling_group.spot.*.name, count.index)
  scheduled_action_name  = format("spot-%s-scheduler-down", module.labels.id)
  min_size               = element(var.schedule_spot_min_size_scaledown, count.index)
  max_size               = element(var.schedule_spot_max_size_scaledown, count.index)
  desired_capacity       = element(var.schedule_desired_spot_scale_down, count.index)
  recurrence             = var.scheduler_down
}


#Module      : AWS AUTOSCALING SCHEDULE
#Description : Provides an AutoScaling Schedule resource.
resource "aws_autoscaling_schedule" "scaleup" {
  count                  = local.autoscaling_enabled_schedule ? length(var.ondemand_instance_type) : 0
  autoscaling_group_name = element(aws_autoscaling_group.on_demand.*.name, count.index)
  scheduled_action_name  = format("%s-scheduler-up", module.labels.id)
  max_size               = element(var.schedule_max_size_scaleup, count.index)
  min_size               = element(var.schedule_min_size_scaleup, count.index)
  desired_capacity       = element(var.schedule_desired_scaleup, count.index)
  recurrence             = var.scheduler_up
}

#Module      : AWS AUTOSCALING SCHEDULE
#Description : Provides an AutoScaling Schedule resource.
resource "aws_autoscaling_schedule" "spot_scaleup" {
  count                  = local.autoscaling_enabled_spot_schedule ? length(var.spot_instance_type) : 0
  autoscaling_group_name = element(aws_autoscaling_group.spot.*.name, count.index)
  scheduled_action_name  = format("spot-%s-scheduler-up", module.labels.id)
  max_size               = element(var.schedule_spot_max_size_scaleup, count.index)
  min_size               = element(var.schedule_spot_min_size_scaleup, count.index)
  desired_capacity       = element(var.schedule_spot_desired_scaleup, count.index)
  recurrence             = var.scheduler_up
}

#Module      : CLOUDWATCH METRIC ALARM CPU HIGH
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count      = local.autoscaling_enabled ? length(var.ondemand_instance_type) : 0
  alarm_name = format("%s%scpu%sutilization%shigh%s", module.labels.id, var.delimiter, var.delimiter, var.delimiter, (count.index))

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.on_demand.*.name, count.index)
  }

  alarm_description = format("Scale up if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [element(aws_autoscaling_policy.scale_up.*.arn, count.index)]
}

#Module      : CLOUDWATCH METRIC ALARM CPU HIGH
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_high_spot" {
  count      = local.spot_autoscaling_enabled ? length(var.spot_instance_type) : 0
  alarm_name = format("%s%scpu%sutilization%shigh-spot%s", module.labels.id, var.delimiter, var.delimiter, var.delimiter, (count.index))

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.spot.*.name, count.index)
  }

  alarm_description = format("Scale up if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [element(aws_autoscaling_policy.scale_up_spot.*.arn, count.index)]
}


#Module      : CLOUDWATCH METRIC ALARM CPU LOW
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = local.autoscaling_enabled ? length(var.ondemand_instance_type) : 0
  alarm_name          = format("%s%scpu%sutilization%slow%s", module.labels.id, var.delimiter, var.delimiter, var.delimiter, (count.index))
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_low_period_seconds
  statistic           = var.cpu_utilization_low_statistic
  threshold           = var.cpu_utilization_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.on_demand.*.name, count.index)
  }

  alarm_description = format("Scale down if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [element(aws_autoscaling_policy.scale_down.*.arn, count.index)]
}

#Module      : CLOUDWATCH METRIC ALARM CPU LOW
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_low_spot" {
  count               = local.spot_autoscaling_enabled ? length(var.spot_instance_type) : 0
  alarm_name          = format("%s%scpu%sutilization%slow-spot%s", module.labels.id, var.delimiter, var.delimiter, var.delimiter, (count.index))
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_low_period_seconds
  statistic           = var.cpu_utilization_low_statistic
  threshold           = var.cpu_utilization_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.spot.*.name, count.index)
  }

  alarm_description = format("Scale down if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [element(aws_autoscaling_policy.scale_down_spot.*.arn, count.index)]
}
