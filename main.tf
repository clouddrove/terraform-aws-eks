#--------------------------------------------------------------------------------------------------------------------------#
#-- This label module is used to create consistent naming for multiple names. --#

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

#--------------------------------------------------------------------------------------------------------------------------#
#-- This Data Blocks are used to retrive and access information from various data sources --#

data "aws_partition" "current" {}             # This data source retrieves information about the current AWS partition.
data "aws_caller_identity" "current" {}       # This data source provides details about the AWS caller identity, which includes information about the user, role, or entity making the Terraform API request.
data "aws_region" "current" {}                # This data source retrieves the current AWS region in which Terraform is being executed. It allows you to determine the region dynamically and use it in your module configuration.
data "aws_iam_session_context" "current" {    # This data source provides information on the IAM source role of an STS assumed role
  arn = data.aws_caller_identity.current.arn  
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- Locals block is used to define local variables --#

locals {
  # Encryption
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled ? join("", aws_kms_key.cluster.*.arn) : null
  }
  aws_policy_prefix = format("arn:%s:iam::aws:policy", join("", data.aws_partition.current.*.partition))

}

#--------------------------------------------------------------------------------------------------------------------------#
#-- This resource block is used to send the Eks cluster logs to cloudwach log group. --#

resource "aws_cloudwatch_log_group" "default" {
  count             = var.enabled && length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${module.labels.id}/cluster"
  retention_in_days = var.cluster_log_retention_period
  tags              = module.labels.tags
  kms_key_id        = join("", aws_kms_key.cloudwatch_log.*.arn)
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- This resource block are used to create the AWS EKS Cluster --#

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
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
    update = var.cluster_update_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
    aws_cloudwatch_log_group.default,

  ]
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- AWS KMS KEY --#

data "aws_iam_policy_document" "cloudwatch" {
  policy_id = "key-policy-cloudwatch"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          join("", data.aws_partition.current.*.partition),
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        format(
          "logs.%s.amazonaws.com",
          data.aws_region.current.name
        )
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "cluster" {
  count                   = var.enabled && var.cluster_encryption_config_enabled ? 1 : 0
  description             = "EKS Cluster ${module.labels.id} Encryption Config KMS Key"
  enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  policy                  = var.cluster_encryption_config_kms_key_policy
  tags                    = module.labels.tags
}

resource "aws_kms_key" "cloudwatch_log" {
  count                   = var.enabled && var.cluster_encryption_config_enabled ? 1 : 0
  description             = "CloudWatch log group ${module.labels.id} Encryption Config KMS Key"
  enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.cloudwatch.json
  tags                    = module.labels.tags
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM Role For Service Account (IRSA) --#

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

#--------------------------------------------------------------------------------------------------------------------------#
#-- EKS Addons --#

resource "aws_eks_addon" "cluster" {
  for_each = var.enabled ? { for addon in var.addons : addon.addon_name => addon } : {}

  cluster_name             = join("", aws_eks_cluster.default.*.name)
  addon_name               = each.key
  addon_version            = lookup(each.value, "addon_version", null)
  resolve_conflicts        = lookup(each.value, "resolve_conflicts", null)
  service_account_role_arn = lookup(each.value, "service_account_role_arn", null)

  tags = module.labels.tags
}


#--------------------------------------------------------------------------------------------------------------------------#
#-- aws-auth configmap --#

# The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster
# to allow worker nodes to join the cluster via AWS IAM role authentication.

# NOTE: To automatically apply the Kubernetes configuration to the cluster (which allows the worker nodes to join the cluster),
# the requirements outlined here must be met

locals {
  certificate_authority_data_list          = coalescelist(aws_eks_cluster.default.*.certificate_authority, [[{ data : "" }]])
  certificate_authority_data_list_internal = local.certificate_authority_data_list[0]
  certificate_authority_data_map           = local.certificate_authority_data_list_internal[0]
  certificate_authority_data               = local.certificate_authority_data_map["data"]

  # Add worker nodes role ARNs (could be from many un-managed worker groups) to the ConfigMap
  # Note that we don't need to do this for managed Node Groups since EKS adds their roles to the ConfigMap automatically
  map_worker_roles = [
    {
      rolearn : join("", aws_iam_role.node_groups.*.arn)
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}

data "template_file" "kubeconfig" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/kubeconfig.tpl")

  vars = {
    server                     = join("", aws_eks_cluster.default.*.endpoint)
    certificate_authority_data = local.certificate_authority_data
    cluster_name               = module.labels.id
  }
}

resource "null_resource" "wait_for_cluster" {
  count      = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  depends_on = [aws_eks_cluster.default[0]]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_command
    interpreter = var.local_exec_interpreter
    environment = {
      ENDPOINT = aws_eks_cluster.default[0].endpoint
    }
  }
}

data "aws_eks_cluster" "eks" {
  count = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  name  = join("", aws_eks_cluster.default.*.id)
}

# Get an authentication token to communicate with the EKS cluster.
# By default (before other roles are added to the Auth ConfigMap), you can authenticate to EKS cluster only by assuming the role that created the cluster.
# `aws_eks_cluster_auth` uses IAM credentials from the AWS provider to generate a temporary token.
# If the AWS provider assumes an IAM role, `aws_eks_cluster_auth` will use the same IAM role to get the auth token.

data "aws_eks_cluster_auth" "eks" {
  count = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  name  = join("", aws_eks_cluster.default.*.id)
}

provider "kubernetes" {
  token                  = join("", data.aws_eks_cluster_auth.eks.*.token)
  host                   = join("", data.aws_eks_cluster.eks.*.endpoint)
  cluster_ca_certificate = base64decode(join("", data.aws_eks_cluster.eks.*.certificate_authority.0.data))
}

resource "kubernetes_config_map" "aws_auth_ignore_changes" {
  count      = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  depends_on = [null_resource.wait_for_cluster[0]]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = yamlencode(distinct(concat(local.map_worker_roles, var.map_additional_iam_roles)))
    mapUsers    = yamlencode(var.map_additional_iam_users)
    mapAccounts = yamlencode(var.map_additional_aws_accounts)
  }

  lifecycle {
    ignore_changes = [data["mapRoles"]]
  }
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM ROLE --#


data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count = var.enabled ? 1 : 0

  name                 = module.labels.id
  assume_role_policy   = join("", data.aws_iam_policy_document.assume_role.*.json)
  permissions_boundary = var.permissions_boundary

  tags = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", join("", data.aws_partition.current.*.partition))
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", join("", data.aws_partition.current.*.partition))
  role       = join("", aws_iam_role.default.*.name)
}

data "aws_iam_policy_document" "service_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInternetGateways",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSubnets",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "service_role" {
  count  = var.enabled ? 1 : 0
  role   = join("", aws_iam_role.default.*.name)
  policy = join("", data.aws_iam_policy_document.service_role.*.json)

  name = module.labels.id

}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM FOR node Group --#

resource "aws_iam_role" "node_groups" {
  count              = var.enabled ? 1 : 0
  name               = "${module.labels.id}-node_group"
  assume_role_policy = join("", data.aws_iam_policy_document.node_group.*.json)
  tags               = module.labels.tags
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM ROLE POLICY ATTACHMENT CNI : Attaches a Managed IAM Policy to an IAM role. --#

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.node_groups.*.name)
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM ROLE POLICY ATTACHMENT EC2 CONTAINER REGISTRY READ ONLY : Attaches a Managed IAM Policy to an IAM role. --#

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.node_groups.*.name)
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_node_group_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.node_groups.*.name)
}

resource "aws_iam_policy" "amazon_eks_worker_node_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = "${module.labels.id}-autoscaler"
  path   = "/"
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_worker_node_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.node_groups.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKSWorkerNodePolicy")
  role       = join("", aws_iam_role.node_groups.*.name)
}

data "aws_iam_policy_document" "node_group" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAutoscaler policy for node group --#

data "aws_iam_policy_document" "amazon_eks_node_group_autoscaler_policy" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ecr:*"
    ]
    resources = ["*"]
  }
}

#--------------------------------------------------------------------------------------------------------------------------#
#-- IAM INSTANCE PROFILE : Provides an IAM instance profile. --#

resource "aws_iam_instance_profile" "default" {
  count = var.enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.node_groups.*.name)
}