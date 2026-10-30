
#Module      : label
#Description : Terraform module to create consistent naming for multiple names.

module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = compact(concat(var.attributes, ["cluster"]))
  label_order = var.label_order
  extra_tags  = var.extra_tags
}

#Cloudwatch: Logs for Eks cluster
resource "aws_cloudwatch_log_group" "default" {
  count             = var.enabled && var.external_cluster == false && length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${module.labels.id}/cluster"
  retention_in_days = var.cluster_log_retention_period
  tags              = module.labels.tags
  kms_key_id        = aws_kms_key.cloudwatch_log[0].arn
}

#tfsec:ignore:aws-eks-no-public-cluster-access  ## To provide eks endpoint public access from local network
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr ## To provide eks endpoint public access from local network
resource "aws_eks_cluster" "default" {
  count                     = var.enabled && var.external_cluster == false ? 1 : 0
  name                      = module.labels.id
  role_arn                  = aws_iam_role.default[0].arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  }
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.eks_additional_security_group_ids
  }

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_config_enabled ? [local.cluster_encryption_config] : []
    content {
      resources = lookup(encryption_config.value, "resources")
      provider {
        key_arn = lookup(encryption_config.value, "provider_key_arn")
      }
    }
  }

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }


  dynamic "zonal_shift_config" {
    for_each = length(var.cluster_zonal_shift_config) > 0 ? [var.cluster_zonal_shift_config] : []

    content {
      enabled = try(zonal_shift_config.value.enabled, false)
    }
  }

  tags = merge(
    module.labels.tags,
    var.eks_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
    aws_cloudwatch_log_group.default,
  ]


  bootstrap_self_managed_addons = local.auto_mode_enabled ? coalesce(var.bootstrap_self_managed_addons, false) : var.bootstrap_self_managed_addons

  dynamic "compute_config" {
    for_each = length(var.cluster_compute_config) > 0 ? [var.cluster_compute_config] : []

    content {
      enabled       = local.auto_mode_enabled
      node_pools    = local.auto_mode_enabled ? try(compute_config.value.node_pools, []) : null
      node_role_arn = local.auto_mode_enabled && length(try(compute_config.value.node_pools, [])) > 0 ? aws_iam_role.eks_auto[0].arn : null
    }
  }

  dynamic "storage_config" {
    for_each = local.auto_mode_enabled ? [1] : []

    content {
      block_storage {
        enabled = local.auto_mode_enabled
      }
    }
  }

  dynamic "kubernetes_network_config" {
    # Not valid on Outposts
    for_each = local.create_outposts_local_cluster ? [] : [1]

    content {
      dynamic "elastic_load_balancing" {
        for_each = local.auto_mode_enabled ? [1] : []

        content {
          enabled = local.auto_mode_enabled
        }
      }

      ip_family         = var.cluster_ip_family
      service_ipv4_cidr = var.cluster_service_ipv4_cidr
      service_ipv6_cidr = var.cluster_service_ipv6_cidr
    }
  }
  upgrade_policy {
    support_type = var.cluster_support_type
  }

  dynamic "zonal_shift_config" {
    for_each = var.enable_zonal_shift ? [1] : []
    content {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions
    ]
  }
}

data "tls_certificate" "cluster" {
  count = var.enabled && var.oidc_provider_enabled && var.external_cluster == false ? 1 : 0
  url   = aws_eks_cluster.default[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "default" {
  count = var.enabled && var.oidc_provider_enabled && var.external_cluster == false ? 1 : 0
  url   = try(aws_eks_cluster.default[0].identity[0].oidc[0].issuer, local.eks_oidc_provider_arn)

  # url = can(regex("^https://", try(aws_eks_cluster.default[0].identity[0].oidc[0].issuer, local.eks_oidc_provider_arn))) ? try(aws_eks_cluster.default[0].identity[0].oidc[0].issuer, local.eks_oidc_provider_arn) : "https://${try(aws_eks_cluster.default[0].identity[0].oidc[0].issuer, local.eks_oidc_provider_arn)}"

  client_id_list  = distinct(compact(concat(["sts.${data.aws_partition.current.dns_suffix}"], var.openid_connect_audiences)))
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]
  tags            = module.labels.tags
}

################################################################################
# Access Entries
################################################################################

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  arn = try(data.aws_caller_identity.current.arn, "")
}

# Access entries are only created when `enable_access_entries = true`
resource "aws_eks_access_entry" "default" {
  for_each = { for k, v in local.merged_access_entries : k => v if var.enabled && var.enable_access_entries }

  cluster_name      = aws_eks_cluster.default[0].id
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)

  tags = merge(module.labels.tags, try(each.value.tags, {}))
}

resource "aws_eks_access_policy_association" "default" {
  for_each = { for k, v in local.flattened_access_entries : "${v.entry_key}_${v.pol_key}" => v if var.enabled && var.enable_access_entries }

  cluster_name  = aws_eks_cluster.default[0].id
  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

  access_scope {
    namespaces = try(each.value.association_access_scope_namespaces, [])
    type       = each.value.association_access_scope_type
  }

  depends_on = [
    aws_eks_access_entry.default,
  ]
}

# Keep existing state working for users who had the resources under the old name
moved {
  from = aws_eks_access_entry.this
  to   = aws_eks_access_entry.default
}

moved {
  from = aws_eks_access_policy_association.this
  to   = aws_eks_access_policy_association.default
}

resource "aws_eks_addon" "cluster" {
  for_each = var.enabled && var.external_cluster == false ? { for addon in var.addons : addon.addon_name => addon } : {}

  cluster_name                = aws_eks_cluster.default[0].name
  addon_name                  = each.key
  addon_version               = lookup(each.value, "addon_version", null)
  resolve_conflicts_on_create = lookup(each.value, "resolve_conflicts", null)
  resolve_conflicts_on_update = lookup(each.value, "resolve_conflicts", null)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)

  tags = module.labels.tags
}