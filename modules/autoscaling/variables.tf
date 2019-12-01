#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}


variable "image_id" {
  type        = string
  default     = ""
  description = "The EC2 image ID to launch."
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  default     = "terminate"
  description = "Shutdown behavior for the instances. Can be `stop` or `terminate`."
}

variable "instance_type" {
  type        = string
  description = "Instance type to launch."
}

variable "iam_instance_profile_name" {
  type        = string
  default     = ""
  description = "The IAM instance profile name to associate with launched instances."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "The SSH key name that should be used for the instance."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of associated security group IDs."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with an instance in a VPC."
}

variable "user_data_base64" {
  type        = string
  default     = ""
  description = "The Base64-encoded user data to provide when launching the instances."
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable/disable detailed monitoring."
}

variable "block_device_mappings" {
  type        = list(string)
  default     = []
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI."
}

variable "max_size" {
  type        = number
  description = "The maximum size of the autoscale group."
}

variable "min_size" {
  type        = number
  description = "The minimum size of the autoscale group."
}


variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch resources in."
}

variable "default_cooldown" {
  type        = number
  default     = 150
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
}

variable "health_check_grace_period" {
  type        = number
  default     = 300
  description = "Time (in seconds) after instance comes into service before checking health."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`."
}

variable "force_delete" {
  type        = bool
  default     = false
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling."
}

variable "load_balancers" {
  type        = list(string)
  default     = []
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
}

variable "termination_policies" {
  type        = list(string)
  default     = ["Default"]
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`."
}

variable "suspended_processes" {
  type        = list(string)
  default     = []
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly."
}


variable "metrics_granularity" {
  type        = string
  default     = "1Minute"
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute."
}

variable "enabled_metrics" {
  type        = list(string)
  default     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  description = "A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances`."
}

variable "wait_for_capacity_timeout" {
  type        = string
  default     = "15m"
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
}

variable "min_elb_capacity" {
  type        = number
  default     = 0
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes."
}

variable "protect_from_scale_in" {
  type        = bool
  default     = false
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
}

variable "service_linked_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services."
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling."
}

variable "scale_up_cooldown_seconds" {
  type        = number
  default     = 150
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
}

variable "scale_up_scaling_adjustment" {
  type        = number
  default     = 1
  description = "The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
}

variable "scale_up_adjustment_type" {
  type        = string
  default     = "ChangeInCapacity"
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity`."
}

variable "scale_up_policy_type" {
  type        = string
  default     = "SimpleScaling"
  description = "The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling`."
}

variable "scale_down_cooldown_seconds" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
}

variable "scale_down_scaling_adjustment" {
  default     = -1
  description = "The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
}

variable "scale_down_adjustment_type" {
  type        = string
  default     = "ChangeInCapacity"
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity`."
}

variable "scale_down_policy_type" {
  type        = string
  default     = "SimpleScaling"
  description = "The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling`."
}

variable "cpu_utilization_high_evaluation_periods" {
  type        = number
  default     = 2
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "cpu_utilization_high_period_seconds" {
  type        = number
  default     = 300
  description = "The period in seconds over which the specified statistic is applied."
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  default     = 90
  description = "The value against which the specified statistic is compared."
}

variable "cpu_utilization_high_statistic" {
  type        = string
  default     = "Average"
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`."
}

variable "cpu_utilization_low_evaluation_periods" {
  type        = number
  default     = 2
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "cpu_utilization_low_period_seconds" {
  type        = number
  default     = 200
  description = "The period in seconds over which the specified statistic is applied."
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  default     = 10
  description = "The value against which the specified statistic is compared."
}

variable "cpu_utilization_low_statistic" {
  type        = string
  default     = "Average"
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`."
}

variable "volume_size" {
  type        = number
  default     = 100
  description = "The size of ebs volume."
}

variable "volume_type" {
  type        = string
  default     = "standard"
  description = "The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`)."
}

variable "ebs_encryption" {
  type        = bool
  default     = false
  description = "Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot_id."
}

variable "kms_key" {
  type        = string
  default     = ""
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
}

###Spot
variable "spot_enabled" {
  type        = bool
  default     = false
  description = "Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances."
}

variable "instance_interruption_behavior" {
  type        = string
  default     = "terminate"
  description = "The behavior when a Spot Instance is interrupted. Can be hibernate, stop, or terminate. (Default: terminate)."
}

variable "max_price" {
  type        = string
  default     = ""
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  default = ""
  description = "Sport instance type to launch."
}

variable "spot_max_size" {
  type        = number
  default     = "1"
  description = "The maximum size of the spot autoscale group."
}

variable "spot_min_size" {
  type        = number
  default     = "1"
  description = "The minimum size of the spot autoscale group."
}

variable "scheduler_down" {
  description = "What is the recurrency for scaling up operations ?"
  default     = "0 19 * * MON-FRI" # 21:00  CET
}

variable "scheduler_up" {
  description = "What is the recurrency for scaling down operations ?"
  default     = "0 6 * * MON-FRI" # 07:00 CET
}
