## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.


#Module      : EKS CLUSTER
#Description : Manages an EKS Cluster.
module "eks_cluster" {
  source                       = "./modules/eks"
  enabled                      = var.enabled
  name                         = var.name
  application                  = var.application
  environment                  = var.environment
  attributes                   = var.attributes
  label_order                  = var.label_order
  tags                         = var.tags
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  kubernetes_version           = var.kubernetes_version
  allowed_security_groups      = var.allowed_security_groups_cluster
  workers_security_group_ids   = [module.eks_workers.security_group_id]
  workers_security_group_count = 1
  allowed_cidr_blocks          = var.allowed_cidr_blocks_cluster
  enabled_cluster_log_types    = var.enabled_cluster_log_types
}

#Module      : EKS Worker
#Description : Manages an EKS Autoscaling.
module "eks_workers" {
  source                                 = "./modules/worker"
  name                                   = var.name
  application                            = var.application
  environment                            = var.environment
  attributes                             = var.attributes
  tags                                   = var.tags
  image_id                               = var.image_id
  instance_type                          = var.instance_type
  vpc_id                                 = var.vpc_id
  subnet_ids                             = var.subnet_ids
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  spot_max_size                          = var.spot_max_size
  spot_min_size                          = var.spot_min_size
  spot_enabled                           = var.spot_enabled
  max_price                              = var.max_price
  volume_size                            = var.volume_size
  ebs_encryption                         = var.ebs_encryption
  kms_key                                = var.kms_key
  volume_type                            = var.volume_type
  spot_instance_type                     = var.spot_instance_type
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  associate_public_ip_address            = var.associate_public_ip_address
  cluster_name                           = module.eks_cluster.eks_cluster_id
  cluster_endpoint                       = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data     = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id              = module.eks_cluster.security_group_id
  allowed_security_groups                = var.allowed_security_groups_workers
  allowed_cidr_blocks                    = var.allowed_cidr_blocks_workers
  enabled                                = var.enabled
  key_name                               = var.key_name
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

}

