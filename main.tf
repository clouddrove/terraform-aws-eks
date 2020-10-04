## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : EKS CLUSTER
#Description : Manages an EKS Cluster.
module "eks_cluster" {
  source                                                    = "./modules/eks"
  enabled                                                   = var.enabled
  name                                                      = var.name
  application                                               = var.application
  environment                                               = var.environment
  managedby                                                 = var.managedby
  attributes                                                = var.attributes
  label_order                                               = var.label_order
  tags                                                      = var.tags
  vpc_id                                                    = var.vpc_id
  subnet_ids                                                = var.eks_subnet_ids
  endpoint_private_access                                   = var.endpoint_private_access
  endpoint_public_access                                    = var.endpoint_public_access
  kubernetes_version                                        = var.kubernetes_version
  allowed_security_groups                                   = var.allowed_security_groups_cluster
  workers_security_group_ids                                = [module.eks_workers.security_group_id]
  workers_security_group_count                              = 1
  allowed_cidr_blocks                                       = var.allowed_cidr_blocks_cluster
  enabled_cluster_log_types                                 = var.enabled_cluster_log_types
  public_access_cidrs                                       = var.public_access_cidrs
  kms_key_arn                                               = var.kms_key_arn
  cluster_encryption_config_resources                       = var.cluster_encryption_config_resources
  cluster_encryption_config_enabled                         = var.cluster_encryption_config_enabled
  cluster_encryption_config_kms_key_enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  cluster_encryption_config_kms_key_deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  cluster_encryption_config_kms_key_policy                  = var.cluster_encryption_config_kms_key_policy
  apply_config_map_aws_auth                                 = var.apply_config_map_aws_auth
  wait_for_cluster_command                                  = var.wait_for_cluster_command
  local_exec_interpreter                                    = var.local_exec_interpreter
  kubernetes_config_map_ignore_role_changes                 = var.kubernetes_config_map_ignore_role_changes
  map_additional_iam_roles                                  = var.map_additional_iam_roles
  map_additional_iam_users                                  = var.map_additional_iam_users
  aws_iam_role_arn                                          = join("", aws_iam_role.default.*.arn)
  oidc_provider_enabled                                     = var.oidc_provider_enabled

}

#Module      : EKS Worker
#Description : Manages an EKS Autoscaling.
module "eks_workers" {
  source                                 = "./modules/worker"
  name                                   = var.name
  application                            = var.application
  environment                            = var.environment
  managedby                              = var.managedby
  label_order                            = var.label_order
  attributes                             = var.attributes
  tags                                   = var.tags
  image_id                               = var.image_id
  instance_type                          = var.instance_type
  vpc_id                                 = var.vpc_id
  subnet_ids                             = var.worker_subnet_ids
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  ami_type                               = var.ami_type
  ami_release_version                    = var.ami_release_version
  desired_size                           = var.desired_size
  kubernetes_labels                      = var.kubernetes_labels
  kubernetes_version                     = var.kubernetes_version
  fargate_enabled                        = var.fargate_enabled
  cluster_namespace                      = var.cluster_namespace
  spot_max_size                          = var.spot_max_size
  spot_min_size                          = var.spot_min_size
  spot_enabled                           = var.spot_enabled
  spot_scale_down_desired                = var.spot_scale_down_desired
  spot_scale_up_desired                  = var.spot_scale_up_desired
  scale_up_desired                       = var.scale_up_desired
  scale_down_desired                     = var.scale_down_desired
  schedule_enabled                       = var.schedule_enabled
  spot_schedule_enabled                  = var.spot_schedule_enabled
  scheduler_down                         = var.scheduler_down
  scheduler_up                           = var.scheduler_up
  min_size_scaledown                     = var.min_size_scaledown
  max_size_scaledown                     = var.max_size_scaledown
  spot_min_size_scaledown                = var.spot_min_size_scaledown
  spot_max_size_scaledown                = var.spot_max_size_scaledown
  max_price                              = var.max_price
  volume_size                            = var.volume_size
  ebs_encryption                         = var.ebs_encryption
  kms_key_arn                            = var.kms_key_arn
  volume_type                            = var.volume_type
  spot_instance_type                     = var.spot_instance_type
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  associate_public_ip_address            = var.associate_public_ip_address
  additional_security_group_ids          = var.additional_security_group_ids
  use_existing_security_group            = var.use_existing_security_group
  workers_security_group_id              = var.workers_security_group_id
  cluster_name                           = module.eks_cluster.eks_cluster_id
  cluster_endpoint                       = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data     = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id              = module.eks_cluster.security_group_id
  allowed_security_groups                = var.allowed_security_groups_workers
  allowed_cidr_blocks                    = var.allowed_cidr_blocks_workers
  enabled                                = var.enabled
  key_name                               = var.key_name
  iam_instance_profile_name              = join("", aws_iam_instance_profile.default.*.name)
  node_security_group_ids                = var.node_security_group_ids
  on_demand_enabled                      = var.on_demand_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
}

    
    
module "node_groups" {
  source                                 = "./modules/node_groups"
  name                                   = var.name
  application                            = var.application
  environment                            = var.environment
  managedby                              = var.managedby
  label_order                            = var.label_order
  attributes                             = var.attributes
  tags                                   = var.tags
#   image_id                               = var.image_id
   instance_types                          = var.instance_type
#   vpc_id                                 = var.vpc_id
  subnet_ids                             = var.worker_subnet_ids
#   health_check_type                      = var.health_check_type
#   min_size                               = var.min_size
#   max_size                               = var.max_size
#   ami_type                               = var.ami_type
#   ami_release_version                    = var.ami_release_version
   disk_size                               = var.disk_size
#   kubernetes_labels                      = var.kubernetes_labels
#   kubernetes_version                     = var.kubernetes_version
#   fargate_enabled                        = var.fargate_enabled
#   cluster_namespace                      = var.cluster_namespace
  max_size                          = var.ng_max_size
  min_size                          = var.ng_min_size
  desired_size                      = var.ng_desired_size
  node_groups                       = var.node_groups
#   enabled                           = var.spot_enabled
#   spot_scale_down_desired                = var.spot_scale_down_desired
#   spot_scale_up_desired                  = var.spot_scale_up_desired
#   scale_up_desired                       = var.scale_up_desired
#   scale_down_desired                     = var.scale_down_desired
#   schedule_enabled                       = var.schedule_enabled
#   spot_schedule_enabled                  = var.spot_schedule_enabled
#   scheduler_down                         = var.scheduler_down
#   scheduler_up                           = var.scheduler_up
#   min_size_scaledown                     = var.min_size_scaledown
#   max_size_scaledown                     = var.max_size_scaledown
#   spot_min_size_scaledown                = var.spot_min_size_scaledown
#   spot_max_size_scaledown                = var.spot_max_size_scaledown
#   max_price                              = var.max_price
#   volume_size                            = var.volume_size
#   ebs_encryption                         = var.ebs_encryption
#   kms_key_arn                            = var.kms_key_arn
#   volume_type                            = var.volume_type
#   spot_instance_type                     = var.spot_instance_type
#   wait_for_capacity_timeout              = var.wait_for_capacity_timeout
#   associate_public_ip_address            = var.associate_public_ip_address
#   additional_security_group_ids          = var.additional_security_group_ids
#   use_existing_security_group            = var.use_existing_security_group
    workers_security_group_id              = var.workers_security_group_id
   cluster_name                           = module.eks_cluster.eks_cluster_id
#   cluster_endpoint                       = module.eks_cluster.eks_cluster_endpoint
#   cluster_certificate_authority_data     = module.eks_cluster.eks_cluster_certificate_authority_data
#   cluster_security_group_id              = module.eks_cluster.security_group_id
#   allowed_security_groups                = var.allowed_security_groups_workers
#   allowed_cidr_blocks                    = var.allowed_cidr_blocks_workers
#   enabled                                = var.enabled
   key_name                               = var.key_name
#   iam_instance_profile_name              = join("", aws_iam_instance_profile.default.*.name)
#   node_security_group_ids                = var.node_security_group_ids
#   on_demand_enabled                      = var.on_demand_enabled
#   cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
#   cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
 aws_iam_role_arn                                          = join("", aws_iam_role.default.*.arn)

}
