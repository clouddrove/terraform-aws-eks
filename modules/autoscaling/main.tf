## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  tags        = var.tags
  enabled     = var.enabled
  managedby   = var.managedby
  attributes  = compact(concat(var.attributes, ["autoscaling"]))
  label_order = var.label_order
}


#Module      : LAUNCH TEMPLATE
#Description : Provides an EC2 launch template resource. Can be used to create instances or
#              auto scaling groups.
resource "aws_launch_template" "on_demand" {
  count = var.enabled && var.ondemand_enabled ? length(var.ondemand_instance_type) : 0

  name_prefix = format("%s%s%s", module.labels.id, var.delimiter,element(var.ondemand_instance_type, (count.index)))
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.volume_size
      encrypted   = var.ebs_encryption
      kms_key_id  = var.kms_key_arn
      volume_type = var.volume_type
    }
  }
  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = element(var.ondemand_instance_type, count.index)
  key_name                             = var.key_name
  user_data                            = var.user_data_base64
  disable_api_termination              = var.disable_api_termination

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  network_interfaces {
    description                 = module.labels.id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "volume"
    tags          = module.labels.tags
  }

  tag_specifications {
    resource_type = "instance"
    tags          = module.labels.tags
  }

  tags = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
} #Module      : LAUNCH TEMPLATE
#Description : Provides an EC2 launch template resource. Can be used to create instances or
#              auto scaling groups.
resource "aws_launch_template" "spot" {
  count = var.enabled && var.spot_enabled ? length(var.spot_instance_type) : 0

  name_prefix = format("%s%sspot-%s", module.labels.id, var.delimiter,element(var.ondemand_instance_type, (count.index)))
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.volume_size
      encrypted   = var.ebs_encryption
      kms_key_id  = var.kms_key_arn
      volume_type = var.volume_type
    }
  }
  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = element(var.spot_instance_type, count.index)
  key_name                             = var.key_name
  user_data                            = var.user_data_base64

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  network_interfaces {
    description                 = module.labels.id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      module.labels.tags,
      {
        "Market_Type" = "spot"
      }
    )
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      module.labels.tags,
      {
        "Market_Type" = "spot"
      }
    )
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = var.instance_interruption_behavior
      max_price                      = element(var.max_price, count.index)
      spot_instance_type             = "one-time"
    }
  }
  tags = merge(
    module.labels.tags,
    {
      "Market_Type" = "spot"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}


#Module      : AUTOSCALING GROUP
#Description : Provides an AutoScaling Group resource.
resource "aws_autoscaling_group" "on_demand" {
  count = var.enabled && var.ondemand_enabled ? length(var.ondemand_instance_type) : 0

  name_prefix               =  format("%s-ondemand%s%s%s", module.labels.id, var.delimiter,element(var.ondemand_instance_type, (count.index)), var.delimiter)
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = element(var.max_size, count.index)
  min_size                  = element(var.min_size, count.index)
  desired_capacity          = element(var.desired_capacity, count.index)
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn

  launch_template {
    id      = element(aws_launch_template.on_demand.*.id, count.index)
    version = element(aws_launch_template.on_demand.*.latest_version, count.index)
  }

  tags = flatten([
    for key in keys(module.labels.tags) :
    {
      key                 = key
      value               = module.labels.tags[key]
      propagate_at_launch = true
    }
  ])
  lifecycle {
    create_before_destroy = true
  }
}

#Module      : AUTOSCALING GROUP
#Description : Provides an AutoScaling Group resource.
resource "aws_autoscaling_group" "spot" {
  count = var.enabled && var.spot_enabled ? length(var.spot_instance_type) : 0

  name_prefix               = format("%s-spot%s%s%s", module.labels.id, var.delimiter,element(var.spot_instance_type, (count.index)), var.delimiter)
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = element(var.spot_max_size, count.index)
  min_size                  = element(var.spot_min_size, count.index)
  desired_capacity          = element(var.spot_desired_capacity, count.index)
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn

  launch_template {
    id      = element(aws_launch_template.spot.*.id, count.index)
    version = element(aws_launch_template.spot.*.latest_version, count.index)
  }

  tags = flatten([
    for key in keys(module.labels.tags) :
    {
      key                 = key
      value               = module.labels.tags[key]
      propagate_at_launch = true
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}