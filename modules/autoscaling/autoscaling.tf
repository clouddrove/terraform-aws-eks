locals {
  autoscaling_enabled      = var.enabled && var.autoscaling_policies_enabled ? true : false
  spot_autoscaling_enabled = var.enabled && var.autoscaling_policies_enabled && var.spot_enabled ? true : false
}

#Module      : AUTOSCALING POLICY UP
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_up" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sup", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default.*.name)

}
#Module      : AUTOSCALING POLICY UP
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_up_spot" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sup-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.spot.*.name)

}

#Module      : AUTOSCALING POLICY DOWN
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_down" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sdown", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default.*.name)
}

#Module      : AUTOSCALING POLICY DOWN
#Description : Provides an AutoScaling Scaling Policy resource.
resource "aws_autoscaling_policy" "scale_down_spot" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sdown-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.spot.*.name)
}

#Module      : CLOUDWATCH METRIC ALARM CPU HIGH
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count      = local.autoscaling_enabled ? 1 : 0
  alarm_name = format("%s%scpu%sutilization%shigh", module.labels.id, var.delimiter, var.delimiter, var.delimiter)

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.default.*.name)
  }

  alarm_description = format("Scale up if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up.*.arn)]
}
#Module      : CLOUDWATCH METRIC ALARM CPU HIGH
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_high_spot" {
  count      = local.spot_autoscaling_enabled ? 1 : 0
  alarm_name = format("%s%scpu%sutilization%shigh-spot", module.labels.id, var.delimiter, var.delimiter, var.delimiter)

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_high_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_high_period_seconds
  statistic           = var.cpu_utilization_high_statistic
  threshold           = var.cpu_utilization_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.spot.*.name)
  }

  alarm_description = format("Scale up if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up_spot.*.arn)]
}

#Module      : CLOUDWATCH METRIC ALARM CPU LOW
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = local.autoscaling_enabled ? 1 : 0
  alarm_name          = format("%s%scpu%sutilization%slow", module.labels.id, var.delimiter, var.delimiter, var.delimiter)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_low_period_seconds
  statistic           = var.cpu_utilization_low_statistic
  threshold           = var.cpu_utilization_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.default.*.name)
  }

  alarm_description = format("Scale down if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down.*.arn)]
}
#Module      : CLOUDWATCH METRIC ALARM CPU LOW
#Description : Provides a CloudWatch Metric Alarm resource.
resource "aws_cloudwatch_metric_alarm" "cpu_low_spot" {
  count               = local.spot_autoscaling_enabled ? 1 : 0
  alarm_name          = format("%s%scpu%sutilization%slow-spot", module.labels.id, var.delimiter, var.delimiter, var.delimiter)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_utilization_low_period_seconds
  statistic           = var.cpu_utilization_low_statistic
  threshold           = var.cpu_utilization_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    AutoScalingGroupName = join("", aws_autoscaling_group.spot.*.name)
  }

  alarm_description = format("Scale down if CPU utilization is above%s for %s seconds", var.cpu_utilization_high_threshold_percent, var.cpu_utilization_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down_spot.*.arn)]
}


resource "aws_autoscaling_schedule" "scaledown" {
  count                  = local.autoscaling_enabled ? 1 : 0
  autoscaling_group_name = "${aws_autoscaling_group.default[0].name}"
  scheduled_action_name  = "${var.name}-scheduler-down"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  recurrence             = "${var.scheduler_down}"
}

resource "aws_autoscaling_schedule" "scaleup" {
  count                  = local.autoscaling_enabled ? 1 : 0
  autoscaling_group_name = "${aws_autoscaling_group.default[0].name}"
  scheduled_action_name  = "${var.name}-scheduler-up"
  max_size               = "${var.max_size}"
  min_size               = "${var.min_size}"
  desired_capacity       = "${var.min_size}"
  recurrence             = "${var.scheduler_up}"
}

resource "aws_autoscaling_schedule" "spot_scaledown" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  autoscaling_group_name = "${aws_autoscaling_group.spot[0].name}"
  scheduled_action_name  = "${var.name}-scheduler-down"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  recurrence             = "${var.scheduler_down}"
}

resource "aws_autoscaling_schedule" "spot_scaleup" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  autoscaling_group_name = "${aws_autoscaling_group.spot[0].name}"
  scheduled_action_name  = "${var.name}-scheduler-up"
  max_size               = "${var.max_size}"
  min_size               = "${var.min_size}"
  desired_capacity       = "${var.min_size}"
  recurrence             = "${var.scheduler_up}"
}
