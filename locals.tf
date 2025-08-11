locals {
  aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
  aws_caller_identity_arn        = data.aws_caller_identity.current.arn
  eks_oidc_provider_arn          = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_issuer_url            = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  eks_cluster_id                 = data.aws_eks_cluster.eks_cluster.id
  aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
  # Encryption
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled && var.external_cluster == false ? aws_kms_key.cluster[0].arn : null
  }
  aws_policy_prefix             = format("arn:%s:iam::aws:policy", data.aws_partition.current.partition)
  create_outposts_local_cluster = length(var.outpost_config) > 0
  auto_mode_enabled             = try(var.cluster_compute_config.enabled, false)

  # EKS auto node group locals
  create_iam_role      = var.enabled
  create_node_iam_role = var.enabled && var.create_node_iam_role && local.auto_mode_enabled
  node_iam_role_name   = coalesce(var.node_iam_role_name, "${var.name}-eks-auto")

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

  #aws_auth locals
  certificate_authority_data_list          = coalescelist(aws_eks_cluster.default[*].certificate_authority, [[{ data : "" }]])
  certificate_authority_data_list_internal = local.certificate_authority_data_list[0]
  certificate_authority_data_map           = local.certificate_authority_data_list_internal[0]
  certificate_authority_data               = local.certificate_authority_data_map["data"]

  # Add worker nodes role ARNs (could be from many un-managed worker groups) to the ConfigMap
  # Note that we don't need to do this for managed Node Groups since EKS adds their roles to the ConfigMap automatically
  map_worker_roles = [
    {
      rolearn : try(aws_iam_role.node_groups[0].arn, var.node_role_arn)
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  # access entry locals
  # This replaces the one time logic from the EKS API with something that can be
  # better controlled by users through Terraform
  bootstrap_cluster_creator_admin_permissions = {
    cluster_creator = {
      principal_arn = try(data.aws_iam_session_context.current.issuer_arn, "")
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Merge the bootstrap behavior with the entries that users provide
  merged_access_entries = merge(
    { for k, v in local.bootstrap_cluster_creator_admin_permissions : k => v if var.enable_cluster_creator_admin_permissions },
    var.access_entries,
  )

  # Flatten out entries and policy associations so users can specify the policy
  # associations within a single entry
  flattened_access_entries = flatten([
    for entry_key, entry_val in local.merged_access_entries : [
      for pol_key, pol_val in lookup(entry_val, "policy_associations", {}) :
      merge(
        {
          principal_arn = entry_val.principal_arn
          entry_key     = entry_key
          pol_key       = pol_key
        },
        { for k, v in {
          association_policy_arn              = pol_val.policy_arn
          association_access_scope_type       = pol_val.access_scope.type
          association_access_scope_namespaces = lookup(pol_val.access_scope, "namespaces", [])
        } : k => v if !contains(["EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX"], lookup(entry_val, "type", "STANDARD")) },
      )
    ]
  ])

  # node_groups locals
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}
