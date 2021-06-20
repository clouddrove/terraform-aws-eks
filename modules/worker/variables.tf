#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-eks"
  description = "Terraform current module repo"
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
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

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the EKS cluster."
}

variable "cluster_endpoint" {
  type        = string
  default     = ""
  description = "EKS cluster endpoint."
}

variable "cluster_certificate_authority_data" {
  type        = string
  default     = ""
  description = "The base64 encoded certificate data required to communicate with the cluster."
}

variable "cluster_security_group_ingress_enabled" {
  type        = bool
  description = "Whether to enable the EKS cluster Security Group as ingress to workers Security Group"
  default     = true
}

variable "cluster_security_group_id" {
  type        = string
  default     = ""
  description = "Security Group ID of the EKS cluster."
}

variable "eks_cluster_managed_security_group_id" {
  type        = list(string)
  default     = []
  description = "Security Group ID of the EKS cluster."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the worker nodes."
}

variable "use_existing_security_group" {
  type        = bool
  description = "If set to `true`, will use variable `workers_security_group_id` to run EKS workers using an existing security group that was created outside of this module, workaround for errors like `count cannot be computed.`"
  default     = false
}
variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional list of security groups that will be attached to the autoscaling group."
}

variable "workers_security_group_id" {
  type        = string
  default     = ""
  description = "The name of the existing security group that will be used in autoscaling group for EKS workers. If empty, a new security group will be created."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the worker nodes."
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  default     = "terminate"
  description = "Shutdown behavior for the instances. Can be `stop` or `terminate`."
}

variable "image_id" {
  type        = string
  default     = ""
  description = "EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images."
}

variable "ondemand_instance_type" {
  type        = list(any)
  default     = []
  description = "Instance type to launch."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "SSH key name that should be used for the instance."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with an instance in a VPC."
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable/disable detailed monitoring."
}

variable "ebs_optimized" {
  type        = bool
  default     = false
  description = "If true, the launched EC2 instance will be EBS-optimized."
}

variable "instance_market_options" {
  type        = list(string)
  default     = []
  description = "The market (purchasing) option for the instances."
}

variable "disable_api_termination" {
  type        = bool
  default     = false
  description = "If `true`, enables EC2 Instance Termination Protection."
}

variable "max_size" {
  type        = list(any)
  default     = []
  description = "The maximum size of the autoscale group."
}

variable "min_size" {
  type        = list(any)
  default     = []
  description = "The minimum size of the autoscale group."
}

variable "desired_capacity" {
  type        = list(any)
  default     = []
  description = "The desired size of the autoscale group."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch resources in."
}

variable "default_cooldown" {
  type        = number
  default     = 300
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

variable "wait_for_elb_capacity" {
  type        = number
  default     = 0
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior."
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

variable "ondemand_enabled" {
  type        = bool
  default     = true
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling."
}

variable "scale_up_cooldown_seconds" {
  type        = number
  default     = 300
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
  default     = 300
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

variable "bootstrap_extra_args" {
  type        = string
  default     = ""
  description = "Passed to the bootstrap.sh script to enable --kublet-extra-args or --use-max-pods."
}

variable "aws_iam_instance_profile_name" {
  type        = string
  default     = ""
  description = "The name of the existing instance profile that will be used in autoscaling group for EKS workers. If empty will create a new instance profile."
}
variable "volume_size" {
  type        = number
  default     = 20
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

variable "kms_key_arn" {
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
  type        = list(any)
  default     = []
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  type        = list(any)
  default     = []
  description = "Sport instance type to launch."
}


variable "spot_max_size" {
  type        = list(any)
  default     = []
  description = "The maximum size of the spot autoscale group."
}

variable "spot_min_size" {
  type        = list(any)
  default     = []
  description = "The minimum size of the spot autoscale group."
}

variable "scheduler_down" {
  type        = string
  default     = "0 19 * * MON-FRI" # 21:00  CET
  description = "What is the recurrency for scaling up operations ?"
}

variable "scheduler_up" {
  type        = string
  default     = "0 6 * * MON-FRI" # 07:00 CET
  description = "What is the recurrency for scaling down operations ?"
}

variable "schedule_min_size_scaledown" {
  type        = list(any)
  default     = []
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "schedule_max_size_scaledown" {
  type        = list(any)
  default     = []
  description = "The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "schedule_spot_min_size_scaledown" {
  type        = list(any)
  default     = []
  description = "The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "schedule_spot_max_size_scaledown" {
  type        = list(any)
  default     = []
  description = "The maximum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}


variable "schedule_desired_scale_down" {
  type        = list(any)
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "schedule_desired_spot_scale_down" {
  type        = list(any)
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}


variable "schedule_desired_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule desired size of the autoscale group."
}

variable "schedule_max_size_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule maximum size of the autoscale group."
}

variable "schedule_min_size_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule minimum size of the autoscale group."
}
variable "schedule_spot_desired_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule desired size of the autoscale group."
}

variable "schedule_spot_max_size_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule maximum size of the autoscale group."
}

variable "schedule_spot_min_size_scaleup" {
  type        = list(any)
  default     = []
  description = "The schedule minimum size of the autoscale group."
}





variable "scale_up_desired" {
  type        = number
  default     = 0
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_up_desired" {
  type        = list(any)
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource"
}

variable "spot_schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource for spot."
}

variable "spot_desired_capacity" {
  type        = list(any)
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "node_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes."
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes"
}

variable "ami_release_version" {
  type        = string
  default     = ""
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version"
}

variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided"
}

variable "kubernetes_labels" {
  type        = map(any)
  default     = {}
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
}

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate profile is enabled or not"
}
variable "cluster_namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace for selection"
}

variable "iam_instance_profile_name" {
  type        = string
  default     = ""
  description = "The Name of instance profile"
}
