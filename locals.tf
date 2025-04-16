locals {
  # Encryption
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled ? aws_kms_key.cluster[0].arn : null
  }
  aws_policy_prefix             = format("arn:%s:iam::aws:policy", data.aws_partition.current.partition)
  create_outposts_local_cluster = length(var.outpost_config) > 0
  auto_mode_enabled             = try(var.cluster_compute_config.enabled, false)

  ###########-------------EKS auto node group locals -------------------############
  ###########-----------------------------------------------------------############
  create_iam_role = var.enabled
  # iam_role_name          = coalesce(var.iam_role_name, "${var.name}-cluster")

  # Standard EKS cluster
  eks_standard_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy = "${local.aws_policy_prefix}/AmazonEKSClusterPolicy",
  } : k => v if !local.create_outposts_local_cluster && !local.auto_mode_enabled }

  # EKS cluster with EKS auto mode enabled
  eks_auto_mode_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy       = "${local.aws_policy_prefix}/AmazonEKSClusterPolicy"
    AmazonEKSComputePolicy       = "${local.aws_policy_prefix}/AmazonEKSComputePolicy"
    AmazonEKSBlockStoragePolicy  = "${local.aws_policy_prefix}/AmazonEKSBlockStoragePolicy"
    AmazonEKSLoadBalancingPolicy = "${local.aws_policy_prefix}/AmazonEKSLoadBalancingPolicy"
    AmazonEKSNetworkingPolicy    = "${local.aws_policy_prefix}/AmazonEKSNetworkingPolicy"
  } : k => v if !local.create_outposts_local_cluster && local.auto_mode_enabled }

  # EKS local cluster on Outposts
  eks_outpost_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy = "${local.aws_policy_prefix}/AmazonEKSLocalOutpostClusterPolicy"
  } : k => v if local.create_outposts_local_cluster && !local.auto_mode_enabled }
}
