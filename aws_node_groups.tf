module "eks_managed_node_group" {
  source = "./node_group/aws_managed"

  for_each = { for k, v in var.managed_node_group : k => v if var.enabled }

  enabled = try(each.value.enabled, true)

  cluster_name    = try(aws_eks_cluster.default[0].name, data.aws_eks_cluster.eks_cluster.name)
  cluster_version = var.kubernetes_version
  vpc_security_group_ids = compact(
    concat(
      aws_security_group.node_group[*].id,
      aws_eks_cluster.default[*].vpc_config[0].cluster_security_group_id,
      var.nodes_additional_security_group_ids

    )
  )
  # EKS Managed Node Group
  name        = try(each.value.name, each.key)
  environment = (try(var.environment, "") != "") ? var.environment : try(each.value.name, "")
  repository  = var.repository
  managedby   = var.managedby
  subnet_ids  = try(each.value.subnet_ids, var.managed_node_group_defaults.subnet_ids, var.subnet_ids)

  min_size     = try(each.value.min_size, var.managed_node_group_defaults.min_size, 1)
  max_size     = try(each.value.max_size, var.managed_node_group_defaults.max_size, 3)
  desired_size = try(each.value.desired_size, var.managed_node_group_defaults.desired_size, 1)

  ami_id              = try(each.value.ami_id, var.managed_node_group_defaults.ami_id, "")
  ami_type            = try(each.value.ami_type, var.managed_node_group_defaults.ami_type, null)
  ami_release_version = try(each.value.ami_release_version, var.managed_node_group_defaults.ami_release_version, null)

  capacity_type        = try(each.value.capacity_type, var.managed_node_group_defaults.capacity_type, null)
  disk_size            = try(each.value.disk_size, var.managed_node_group_defaults.disk_size, null)
  force_update_version = try(each.value.force_update_version, var.managed_node_group_defaults.force_update_version, null)
  instance_types       = try(each.value.instance_types, var.managed_node_group_defaults.instance_types, null)
  labels               = try(each.value.labels, var.managed_node_group_defaults.labels, null)

  remote_access = try(each.value.remote_access, var.managed_node_group_defaults.remote_access, {})
  taints        = try(each.value.taints, var.managed_node_group_defaults.taints, {})
  update_config = try(each.value.update_config, var.managed_node_group_defaults.update_config, {})
  timeouts      = try(each.value.timeouts, var.managed_node_group_defaults.timeouts, {})

  #------------ASG-Schedule--------------------------------------------------
  create_schedule = try(each.value.create_schedule, var.managed_node_group_defaults.create_schedule, true)
  schedules       = try(each.value.schedules, var.managed_node_group_defaults.schedules, var.schedules)

  # Launch Template
  launch_template_description = try(each.value.launch_template_description, var.managed_node_group_defaults.launch_template_description, "Custom launch template for ${try(each.value.name, each.key)} EKS managed node group")
  launch_template_tags        = try(each.value.launch_template_tags, var.managed_node_group_defaults.launch_template_tags, {})

  ebs_optimized = try(each.value.ebs_optimized, var.managed_node_group_defaults.ebs_optimized, null)
  key_name      = try(each.value.key_name, var.managed_node_group_defaults.key_name, null)
  kms_key_id    = try(each.value.kms_key_id, var.managed_node_group_defaults.ebs_optimized, null)

  launch_template_default_version        = try(each.value.launch_template_default_version, var.managed_node_group_defaults.launch_template_default_version, null)
  update_launch_template_default_version = try(each.value.update_launch_template_default_version, var.managed_node_group_defaults.update_launch_template_default_version, true)
  disable_api_termination                = try(each.value.disable_api_termination, var.managed_node_group_defaults.disable_api_termination, null)
  kernel_id                              = try(each.value.kernel_id, var.managed_node_group_defaults.kernel_id, null)
  ram_disk_id                            = try(each.value.ram_disk_id, var.managed_node_group_defaults.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, var.managed_node_group_defaults.block_device_mappings, {})
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.managed_node_group_defaults.capacity_reservation_specification, null)
  cpu_options                        = try(each.value.cpu_options, var.managed_node_group_defaults.cpu_options, null)
  credit_specification               = try(each.value.credit_specification, var.managed_node_group_defaults.credit_specification, null)
  enclave_options                    = try(each.value.enclave_options, var.managed_node_group_defaults.enclave_options, null)
  license_specifications             = try(each.value.license_specifications, var.managed_node_group_defaults.license_specifications, null)
  metadata_options                   = try(each.value.metadata_options, var.managed_node_group_defaults.metadata_options, local.metadata_options)
  enable_monitoring                  = try(each.value.enable_monitoring, var.managed_node_group_defaults.enable_monitoring, true)
  network_interfaces                 = try(each.value.network_interfaces, var.managed_node_group_defaults.network_interfaces, [])
  placement                          = try(each.value.placement, var.managed_node_group_defaults.placement, null)

  # IAM role
  iam_role_arn = try(aws_iam_role.node_groups[0].arn, var.node_role_arn)

  tags = merge(var.tags, try(each.value.tags, var.managed_node_group_defaults.tags, {}))
}



