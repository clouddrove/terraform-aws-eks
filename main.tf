
#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
#tfsec:ignore:aws-eks-no-public-cluster-access  ## To provide eks endpoint public access from local network
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr ## To provide eks endpoint public access from local network 

module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = compact(concat(var.attributes, ["cluster"]))
  extra_tags  = var.tags
  label_order = var.label_order
}

#Cloudwatch: Logs for Eks cluster
resource "aws_cloudwatch_log_group" "default" {
  count             = var.enabled && length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${module.labels.id}/cluster"
  retention_in_days = var.cluster_log_retention_period
  tags              = module.labels.tags
  kms_key_id        = join("", aws_kms_key.cloudwatch_log.*.arn)
}


resource "aws_eks_cluster" "default" {
  count                     = var.enabled ? 1 : 0
  name                      = module.labels.id
  role_arn                  = join("", aws_iam_role.default.*.arn)
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  tags                      = module.labels.tags


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

  dynamic "kubernetes_network_config" {
    # Not valid on Outposts
    for_each = local.create_outposts_local_cluster ? [] : [1]

    content {
      ip_family         = var.cluster_ip_family
      service_ipv4_cidr = var.cluster_service_ipv4_cidr
      service_ipv6_cidr = var.cluster_service_ipv6_cidr
    }
  }

  dynamic "outpost_config" {
    for_each = local.create_outposts_local_cluster ? [var.outpost_config] : []

    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type
      outpost_arns                = outpost_config.value.outpost_arns
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
    aws_cloudwatch_log_group.default,

  ]
}

data "tls_certificate" "cluster" {
  count = var.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = join("", aws_eks_cluster.default.*.identity.0.oidc.0.issuer)
}

resource "aws_iam_openid_connect_provider" "default" {
  count = var.enabled && var.oidc_provider_enabled ? 1 : 0
  url   = join("", aws_eks_cluster.default.*.identity.0.oidc.0.issuer)

  client_id_list  = distinct(compact(concat(["sts.${data.aws_partition.current.dns_suffix}"], var.openid_connect_audiences)))
  thumbprint_list = [join("", data.tls_certificate.cluster.*.certificates.0.sha1_fingerprint)]
  tags            = module.labels.tags
}

resource "aws_eks_addon" "cluster" {
  for_each = var.enabled ? { for addon in var.addons : addon.addon_name => addon } : {}

  cluster_name                = join("", aws_eks_cluster.default.*.name)
  addon_name                  = each.key
  addon_version               = lookup(each.value, "addon_version", null)
  resolve_conflicts_on_create = lookup(each.value, "resolve_conflicts", null)
  resolve_conflicts_on_update = lookup(each.value, "resolve_conflicts", null)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)

  tags = module.labels.tags
}
