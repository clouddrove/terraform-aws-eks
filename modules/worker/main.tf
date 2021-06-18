## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  enabled = var.enabled ? true : false
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  tags        = local.tags
  attributes  = compact(concat(var.attributes, ["workers"]))
  label_order = var.label_order
}

#Module      : SECURITY GROUP
#Description : Provides a security group resource.
resource "aws_security_group" "default" {
  count       = var.enabled && var.use_existing_security_group == false ? 1 : 0
  name        = module.labels.id
  description = "Security Group for EKS worker nodes"
  vpc_id      = var.vpc_id
  tags        = module.labels.tags
}

#Module      : SECURITY GROUP RULE EGRESS
#Description : Provides a security group rule resource. Represents a single egress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "egress" {
  count             = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

#Module      : SECURITY GROUP RULE INGRESS SELF
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_self" {
  count                    = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE INGRESS CLUSTER
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_cluster" {
  count                    = var.enabled && var.cluster_security_group_ingress_enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = var.cluster_security_group_id
  type                     = "ingress"
}

#Module      : SECURITY GROUP
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled && var.use_existing_security_group == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE CIDR BLOCK
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}


module "autoscale_group" {
  source = "../autoscaling"

  enabled     = local.enabled
  name        = var.name
  application = var.application
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  label_order = var.label_order

  image_id                  = var.image_id
  iam_instance_profile_name = var.iam_instance_profile_name
  security_group_ids = compact(
    concat(
      [
        var.use_existing_security_group == false ? join("", aws_security_group.default.*.id) : var.workers_security_group_id
      ],
      var.additional_security_group_ids,
      var.eks_cluster_managed_security_group_id
    )
  )
  user_data_base64 = base64encode(join("", data.template_file.userdata.*.rendered))
  tags             = module.labels.tags

  ondemand_instance_type                          = var.ondemand_instance_type
  subnet_ids                      = var.subnet_ids
  min_size                        = var.min_size
  max_size                        = var.max_size
  desired_capacity                = var.desired_capacity
  disable_api_termination         = var.disable_api_termination
  spot_max_size                   = var.spot_max_size
  spot_min_size                   = var.spot_min_size
  spot_desired_capacity           = var.spot_desired_capacity
  spot_enabled                    = var.spot_enabled
  scheduler_down                  = var.scheduler_down
  scheduler_up                    = var.scheduler_up
  schedule_min_size_scaledown     = var.schedule_min_size_scaledown
  schedule_max_size_scaledown     = var.schedule_max_size_scaledown
  schedule_max_size_scaleup       = var.schedule_max_size_scaleup
  schedule_desired_scaleup        = var.schedule_desired_scaleup
  schedule_min_size_scaleup       = var.schedule_min_size_scaleup
  schedule_spot_desired_scaleup   = var.schedule_spot_desired_scaleup
  schedule_spot_max_size_scaleup = var.schedule_spot_max_size_scaleup
  schedule_spot_min_size_scaleup  = var.schedule_spot_min_size_scaleup


  schedule_spot_min_size_scaledown        = var.schedule_spot_min_size_scaledown
  schedule_spot_max_size_scaledown        = var.schedule_spot_max_size_scaledown
  schedule_enabled                        = var.schedule_enabled
  spot_schedule_enabled                   = var.spot_schedule_enabled
  schedule_desired_spot_scale_down        = var.schedule_desired_spot_scale_down
  spot_scale_up_desired                   = var.spot_scale_up_desired
  scale_up_desired                        = var.scale_up_desired
  schedule_desired_scale_down             = var.schedule_desired_scale_down
  max_price                               = var.max_price
  volume_size                             = var.volume_size
  ebs_encryption                          = var.ebs_encryption
  kms_key_arn                             = var.kms_key_arn
  volume_type                             = var.volume_type
  spot_instance_type                      = var.spot_instance_type
  associate_public_ip_address             = var.associate_public_ip_address
  instance_initiated_shutdown_behavior    = var.instance_initiated_shutdown_behavior
  key_name                                = var.key_name
  enable_monitoring                       = var.enable_monitoring
  load_balancers                          = var.load_balancers
  health_check_grace_period               = var.health_check_grace_period
  health_check_type                       = var.health_check_type
  min_elb_capacity                        = var.min_elb_capacity
  target_group_arns                       = var.target_group_arns
  default_cooldown                        = var.default_cooldown
  force_delete                            = var.force_delete
  termination_policies                    = var.termination_policies
  suspended_processes                     = var.suspended_processes
  enabled_metrics                         = var.enabled_metrics
  metrics_granularity                     = var.metrics_granularity
  wait_for_capacity_timeout               = var.wait_for_capacity_timeout
  protect_from_scale_in                   = var.protect_from_scale_in
  service_linked_role_arn                 = var.service_linked_role_arn
  ondemand_enabled                       = var.ondemand_enabled
  scale_up_cooldown_seconds               = var.scale_up_cooldown_seconds
  scale_up_scaling_adjustment             = var.scale_up_scaling_adjustment
  scale_up_adjustment_type                = var.scale_up_adjustment_type
  scale_up_policy_type                    = var.scale_up_policy_type
  scale_down_cooldown_seconds             = var.scale_down_cooldown_seconds
  scale_down_scaling_adjustment           = var.scale_down_scaling_adjustment
  scale_down_adjustment_type              = var.scale_down_adjustment_type
  scale_down_policy_type                  = var.scale_down_policy_type
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period_seconds     = var.cpu_utilization_high_period_seconds
  cpu_utilization_high_threshold_percent  = var.cpu_utilization_high_threshold_percent
  cpu_utilization_high_statistic          = var.cpu_utilization_high_statistic
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period_seconds      = var.cpu_utilization_low_period_seconds
  cpu_utilization_low_statistic           = var.cpu_utilization_low_statistic
  cpu_utilization_low_threshold_percent   = var.cpu_utilization_low_threshold_percent
}

data "template_file" "userdata" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/userdata.tpl")

  vars = {
    cluster_endpoint           = var.cluster_endpoint
    certificate_authority_data = var.cluster_certificate_authority_data
    cluster_name               = var.cluster_name
    bootstrap_extra_args       = var.bootstrap_extra_args
  }
}
