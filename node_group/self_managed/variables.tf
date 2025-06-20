#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-eks"
  description = "Terraform current module repo"
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

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
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


variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}


#-----------------------------------------------------------EKS---------------------------------------------------------
variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "cluster_endpoint" {
  type        = string
  default     = ""
  description = "Endpoint of associated EKS cluster"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the EKS cluster."
}

variable "cluster_auth_base64" {
  description = "Base64 encoded CA of associated EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  default     = null
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
}

variable "pre_bootstrap_user_data" {
  type        = string
  default     = ""
  description = "User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `platform` = `bottlerocket`"
}

variable "post_bootstrap_user_data" {
  type        = string
  default     = ""
  description = "User data that is appended to the user data script after of the EKS bootstrap script. Not used when `platform` = `bottlerocket`"
}

variable "bootstrap_extra_args" {
  type        = string
  default     = ""
  description = "Additional arguments passed to the bootstrap script. When `platform` = `bottlerocket`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data"
}

#-----------------------------------------------------------Launch_Template---------------------------------------------------------

variable "ebs_optimized" {
  type        = bool
  default     = null
  description = "If true, the launched EC2 instance will be EBS-optimized"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "The type of the instance to launch"
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with an instance in a VPC."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of associated security group IDs."
}

variable "disable_api_termination" {
  type        = bool
  default     = null
  description = "If true, enables EC2 instance termination protection"
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  default     = null
  description = "Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
}

variable "kernel_id" {
  type        = string
  default     = null
  description = "The kernel ID"
}

variable "ram_disk_id" {
  type        = string
  default     = null
  description = "The ID of the ram disk"
}

variable "block_device_mappings" {
  type        = any
  default     = {}
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The KMS ID of EBS volume"
}

variable "capacity_reservation_specification" {
  type        = any
  default     = null
  description = "Targeting for EC2 capacity reservations"
}

variable "cpu_options" {
  type        = map(string)
  default     = null
  description = "The CPU options for the instance"
}

variable "credit_specification" {
  type        = map(string)
  default     = null
  description = "Customize the credit specification of the instance"
}

variable "enclave_options" {
  type        = map(string)
  default     = null
  description = "Enable Nitro Enclaves on launched instances"
}

variable "hibernation_options" {
  type        = map(string)
  default     = null
  description = "The hibernation options for the instance"
}

variable "instance_market_options" {
  type        = any
  default     = null
  description = "The market (purchasing) option for the instance"
}

variable "license_specifications" {
  type        = map(string)
  default     = null
  description = "A list of license specifications to associate with"
}

variable "metadata_options" {
  type = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  description = "Customize the metadata options for the instance"

}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enables/disables detailed monitoring"
}
variable "iam_instance_profile_arn" {
  type        = string
  default     = null
  description = "Amazon Resource Name (ARN) of an existing IAM instance profile that provides permissions for the node group"
}


variable "placement" {
  type        = map(string)
  default     = null
  description = "The placement of the instance"
}

#------------------------------------------------Auto-Scaling-----------------------------------------------------------
variable "use_mixed_instances_policy" {
  type        = bool
  default     = false
  description = "Determines whether to use a mixed instances policy in the autoscaling group or not"
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "A list of one or more availability zones for the group. Used for EC2-Classic and default subnets when not specified with `subnet_ids` argument. Conflicts with `subnet_ids`"
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = 1
}

variable "capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled"
  type        = bool
  default     = null
}

variable "min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  type        = number
  default     = null
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior."
  type        = number
  default     = null
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  type        = string
  default     = null
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
  default     = null
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = false
}

variable "target_group_arns" {
  description = "A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = null
}

variable "force_delete" {
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  type        = bool
  default     = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default`"
  type        = list(string)
  default     = null
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your Auto Scaling Group from functioning properly"
  type        = list(string)
  default     = null
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds"
  type        = number
  default     = null
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`"
  type        = list(string)
  default     = null
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is `1Minute`"
  type        = string
  default     = null
}

variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
  default     = null
}
variable "initial_lifecycle_hooks" {
  description = "One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource"
  type        = list(map(string))
  default     = []
}

variable "instance_refresh" {
  description = "If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated"
  type        = any
  default     = null
}

variable "mixed_instances_policy" {
  description = "Configuration block containing settings to define launch targets for Auto Scaling groups"
  type        = any
  default     = null
}

variable "warm_pool" {
  description = "If this block is configured, add a Warm Pool to the specified Auto Scaling group"
  type        = any
  default     = null
}

variable "delete_timeout" {
  description = "Delete timeout to wait for destroying autoscaling group"
  type        = string
  default     = null
}

variable "propagate_tags" {
  description = "A list of tag blocks. Each element should have keys named `key`, `value`, and `propagate_at_launch`"
  type        = list(map(string))
  default     = []
}

#-----------------------------------------------TimeOuts----------------------------------------------------------------

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

#---------------------------------------------------ASG-schedule-----------------------------------------------------------
variable "create_schedule" {
  description = "Determines whether to create autoscaling group schedule or not"
  type        = bool
  default     = true
}

variable "schedules" {
  description = "Map of autoscaling group schedule to create"
  type        = map(any)
  default     = {}
}
