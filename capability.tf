locals {
  # Only manage capabilities when the module (and cluster) is enabled
  capabilities = var.enabled ? var.capabilities : {}

  # Capabilities for which we need to create an IAM role (i.e. the caller
  # did not bring their own `iam_role_arn`)
  capabilities_iam_roles_to_create = {
    for k, v in local.capabilities : k => v
    if try(v.create_iam_role, true) && try(v.iam_role_arn, null) == null
  }

  # Flatten `iam_role_policy_arns` per capability so they can be attached
  # with a single for_each resource
  capabilities_iam_role_policy_attachments = merge([
    for capability_key, capability_value in local.capabilities_iam_roles_to_create : {
      for policy_arn in try(capability_value.iam_role_policy_arns, []) :
      "${capability_key}-${policy_arn}" => {
        capability_key = capability_key
        policy_arn     = policy_arn
      }
    }
  ]...)
}

# All EKS Capability roles must trust the `capabilities.eks.amazonaws.com`
# service principal. Ref: https://docs.aws.amazon.com/eks/latest/userguide/capability-role.html
data "aws_iam_policy_document" "capability_assume_role" {
  for_each = local.capabilities_iam_roles_to_create

  statement {
    sid    = "EKSCapabilityAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["capabilities.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "capability" {
  for_each = local.capabilities_iam_roles_to_create

  name                 = try(each.value.iam_role_name, format("%s-%s-capability", module.labels.id, each.key))
  path                 = try(each.value.iam_role_path, null)
  description          = try(each.value.iam_role_description, "IAM role for the ${each.key} EKS Capability")
  assume_role_policy   = data.aws_iam_policy_document.capability_assume_role[each.key].json
  permissions_boundary = try(each.value.iam_role_permissions_boundary, var.permissions_boundary)

  tags = merge(module.labels.tags, try(each.value.tags, {}))
}

# Optional AWS managed/customer managed policy attachments, e.g. for an ACK
# capability that is not using IAM Role Selectors
resource "aws_iam_role_policy_attachment" "capability" {
  for_each = local.capabilities_iam_role_policy_attachments

  role       = aws_iam_role.capability[each.value.capability_key].name
  policy_arn = each.value.policy_arn
}

# Optional inline policy document for a capability role
resource "aws_iam_role_policy" "capability" {
  for_each = {
    for k, v in local.capabilities_iam_roles_to_create : k => v
    if try(v.iam_role_policy, null) != null
  }

  name   = format("%s-%s-capability", module.labels.id, each.key)
  role   = aws_iam_role.capability[each.key].name
  policy = each.value.iam_role_policy
}

resource "aws_eks_capability" "this" {
  for_each = local.capabilities

  cluster_name              = local.eks_cluster_id
  capability_name           = try(each.value.capability_name, each.key)
  type                      = each.value.type
  delete_propagation_policy = try(each.value.delete_propagation_policy, "RETAIN")
  role_arn                  = try(each.value.iam_role_arn, aws_iam_role.capability[each.key].arn)

  dynamic "configuration" {
    for_each = try(each.value.configuration, null) != null ? [each.value.configuration] : []

    content {
      dynamic "argo_cd" {
        for_each = try(configuration.value.argo_cd, null) != null ? [configuration.value.argo_cd] : []

        content {
          namespace = try(argo_cd.value.namespace, null)

          dynamic "aws_idc" {
            for_each = try(argo_cd.value.aws_idc, null) != null ? [argo_cd.value.aws_idc] : []

            content {
              idc_instance_arn = aws_idc.value.idc_instance_arn
              idc_region       = try(aws_idc.value.idc_region, null)
            }
          }

          dynamic "network_access" {
            for_each = try(argo_cd.value.network_access, null) != null ? [argo_cd.value.network_access] : []

            content {
              vpce_ids = try(network_access.value.vpce_ids, null)
            }
          }

          dynamic "rbac_role_mapping" {
            for_each = try(argo_cd.value.rbac_role_mapping, [])

            content {
              role = rbac_role_mapping.value.role

              dynamic "identity" {
                for_each = rbac_role_mapping.value.identity

                content {
                  id   = identity.value.id
                  type = identity.value.type
                }
              }
            }
          }
        }
      }
    }
  }

  tags = merge(module.labels.tags, try(each.value.tags, {}))

  depends_on = [
    aws_eks_cluster.default,
  ]
}
