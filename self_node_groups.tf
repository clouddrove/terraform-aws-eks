################################################################################
# Self Managed Node Group
################################################################################

module "self_managed_node_group" {
  source = "./node_group/self_managed"

  for_each = { for k, v in var.self_node_groups : k => v if var.enabled }

  enabled = try(each.value.enabled, true)

  cluster_name = aws_eks_cluster.default[0].name
  security_group_ids = compact(
    concat(
      aws_security_group.node_group[*].id,
      aws_eks_cluster.default[*].vpc_config[0].cluster_security_group_id
    )
  )

  iam_instance_profile_arn = aws_iam_instance_profile.default[0].arn

  # Autoscaling Group
  name        = try(each.value.name, each.key)
  environment = var.environment
  repository  = var.repository


  availability_zones = try(each.value.availability_zones, var.self_node_group_defaults.availability_zones, null)
  subnet_ids         = try(each.value.subnet_ids, var.self_node_group_defaults.subnet_ids, var.subnet_ids)
  key_name           = try(each.value.key_name, var.self_node_group_defaults.key_name, null)

  min_size                  = try(each.value.min_size, var.self_node_group_defaults.min_size, 0)
  max_size                  = try(each.value.max_size, var.self_node_group_defaults.max_size, 3)
  desired_size              = try(each.value.desired_size, var.self_node_group_defaults.desired_size, 1)
  capacity_rebalance        = try(each.value.capacity_rebalance, var.self_node_group_defaults.capacity_rebalance, null)
  min_elb_capacity          = try(each.value.min_elb_capacity, var.self_node_group_defaults.min_elb_capacity, null)
  wait_for_elb_capacity     = try(each.value.wait_for_elb_capacity, var.self_node_group_defaults.wait_for_elb_capacity, null)
  wait_for_capacity_timeout = try(each.value.wait_for_capacity_timeout, var.self_node_group_defaults.wait_for_capacity_timeout, null)
  default_cooldown          = try(each.value.default_cooldown, var.self_node_group_defaults.default_cooldown, null)
  protect_from_scale_in     = try(each.value.protect_from_scale_in, var.self_node_group_defaults.protect_from_scale_in, null)

  target_group_arns         = try(each.value.target_group_arns, var.self_node_group_defaults.target_group_arns, null)
  placement_group           = try(each.value.placement_group, var.self_node_group_defaults.placement_group, null)
  health_check_type         = try(each.value.health_check_type, var.self_node_group_defaults.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, var.self_node_group_defaults.health_check_grace_period, null)

  force_delete          = try(each.value.force_delete, var.self_node_group_defaults.force_delete, null)
  termination_policies  = try(each.value.termination_policies, var.self_node_group_defaults.termination_policies, null)
  suspended_processes   = try(each.value.suspended_processes, var.self_node_group_defaults.suspended_processes, null)
  max_instance_lifetime = try(each.value.max_instance_lifetime, var.self_node_group_defaults.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, var.self_node_group_defaults.enabled_metrics, null)
  metrics_granularity     = try(each.value.metrics_granularity, var.self_node_group_defaults.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, var.self_node_group_defaults.service_linked_role_arn, null)

  initial_lifecycle_hooks    = try(each.value.initial_lifecycle_hooks, var.self_node_group_defaults.initial_lifecycle_hooks, [])
  instance_refresh           = try(each.value.instance_refresh, var.self_node_group_defaults.instance_refresh, null)
  use_mixed_instances_policy = try(each.value.use_mixed_instances_policy, var.self_node_group_defaults.use_mixed_instances_policy, false)
  mixed_instances_policy     = try(each.value.mixed_instances_policy, var.self_node_group_defaults.mixed_instances_policy, null)
  warm_pool                  = try(each.value.warm_pool, var.self_node_group_defaults.warm_pool, null)

  #------------ASG-Schedule--------------------------------------------------
  create_schedule = try(each.value.create_schedule, var.self_node_group_defaults.create_schedule, false)
  schedules       = try(each.value.schedules, var.self_node_group_defaults.schedules, var.schedules)

  delete_timeout = try(each.value.delete_timeout, var.self_node_group_defaults.delete_timeout, null)

  # User data
  cluster_endpoint         = try(aws_eks_cluster.default[0].endpoint, "")
  cluster_auth_base64      = try(aws_eks_cluster.default[0].certificate_authority[0].data, "")
  pre_bootstrap_user_data  = try(each.value.pre_bootstrap_user_data, var.self_node_group_defaults.pre_bootstrap_user_data, "")
  post_bootstrap_user_data = try(each.value.post_bootstrap_user_data, var.self_node_group_defaults.post_bootstrap_user_data, "")
  bootstrap_extra_args     = try(each.value.bootstrap_extra_args, var.self_node_group_defaults.bootstrap_extra_args, "")

  # Launch Template


  ebs_optimized      = try(each.value.ebs_optimized, var.self_node_group_defaults.ebs_optimized, true)
  kubernetes_version = try(each.value.kubernetes_version, var.self_node_group_defaults.cluster_version, var.kubernetes_version)
  instance_type      = try(each.value.instance_type, var.self_node_group_defaults.instance_type, "m6i.large")
  kms_key_id         = try(each.value.kms_key_id, var.self_node_group_defaults.ebs_optimized, null)

  disable_api_termination              = try(each.value.disable_api_termination, var.self_node_group_defaults.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, var.self_node_group_defaults.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, var.self_node_group_defaults.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, var.self_node_group_defaults.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, var.self_node_group_defaults.block_device_mappings, [])
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.self_node_group_defaults.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, var.self_node_group_defaults.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, var.self_node_group_defaults.credit_specification, null)
  enclave_options                    = try(each.value.enclave_options, var.self_node_group_defaults.enclave_options, null)
  hibernation_options                = try(each.value.hibernation_options, var.self_node_group_defaults.hibernation_options, null)
  instance_market_options            = try(each.value.instance_market_options, var.self_node_group_defaults.instance_market_options, null)
  license_specifications             = try(each.value.license_specifications, var.self_node_group_defaults.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, var.self_node_group_defaults.metadata_options, local.metadata_options)
  enable_monitoring                  = try(each.value.enable_monitoring, var.self_node_group_defaults.enable_monitoring, false)
  #  network_interfaces                 = try(each.value.network_interfaces, var.self_node_group_defaults.network_interfaces, [])
  placement = try(each.value.placement, var.self_node_group_defaults.placement, null)

  tags           = merge(var.tags, try(each.value.tags, var.self_node_group_defaults.tags, {}))
  propagate_tags = try(each.value.propagate_tags, var.self_node_group_defaults.propagate_tags, [])

}


