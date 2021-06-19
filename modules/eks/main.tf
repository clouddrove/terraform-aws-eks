## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

locals {
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled && var.cluster_encryption_config_enabled && var.kms_key_arn == "" ? join("", aws_kms_key.cluster.*.arn) : var.kms_key_arn
  }
}
#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = compact(concat(var.attributes, ["cluster"]))
  label_order = var.label_order
}

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

data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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


resource "aws_cloudwatch_log_group" "default" {
  count             = var.enabled && length(var.enabled_cluster_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${module.labels.id}/cluster"
  retention_in_days = var.cluster_log_retention_period
  tags              = module.labels.tags
  kms_key_id        = join("", aws_kms_key.cloudwatch_log.*.arn)
}

resource "aws_kms_key" "cluster" {
  count                   = var.enabled && var.cluster_encryption_config_enabled && var.kms_key_arn == "" ? 1 : 0
  description             = "EKS Cluster ${module.labels.id} Encryption Config KMS Key"
  enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  policy                  = var.cluster_encryption_config_kms_key_policy
  tags                    = module.labels.tags
}

resource "aws_kms_key" "cloudwatch_log" {
  count                   = var.enabled && var.cluster_encryption_config_enabled && var.kms_key_arn == "" ? 1 : 0
  description             = "CloudWatch log group ${module.labels.id} Encryption Config KMS Key"
  enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.cloudwatch.json
  tags                    = module.labels.tags
}

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.labels.tags
}

#Module      : IAM ROLE POLICY ATTACHMENT CLUSTER
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", join("", data.aws_partition.current.*.partition))
  role       = join("", aws_iam_role.default.*.name)
}

#Module      : IAM ROLE POLICY ATTACHMENT SERVICE
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", join("", data.aws_partition.current.*.partition))
  role       = join("", aws_iam_role.default.*.name)
}


# AmazonEKSClusterPolicy managed policy doesn't contain all necessary permissions to create
# ELB service-linked role required during LB provisioning by Kubernetes.
# Because of that, on a new AWS account (where load balancers have not been provisioned yet, `nginx-ingress` fails to provision a load balancer

data "aws_iam_policy_document" "cluster_elb_service_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSubnets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cluster_elb_service_role" {
  count  = var.enabled ? 1 : 0
  name   = module.labels.id
  role   = join("", aws_iam_role.default.*.name)
  policy = join("", data.aws_iam_policy_document.cluster_elb_service_role.*.json)
}

#Module      : SECURITY GROUP
#Description : Provides a security group resource.
resource "aws_security_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = module.labels.id
  description = "Security Group for EKS cluster"
  vpc_id      = var.vpc_id
  tags        = module.labels.tags
}

#Module      : SECURITY GROUP RULE EGRESS
#Description : Provides a security group rule resource. Represents a single egress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

#Module      : SECURITY GROUP RULE INGRESS WORKER
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_workers" {
  count                    = var.enabled ? var.workers_security_group_count : 0
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = element(var.workers_security_group_ids, count.index)
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE INGRESS
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE CIDR BLOCK
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

#Module      : EKS CLUSTER
#Description : Manages an EKS Cluster.
resource "aws_eks_cluster" "default" {
  count                     = var.enabled ? 1 : 0
  name                      = module.labels.id
  role_arn                  = join("", aws_iam_role.default.*.arn)
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  tags                      = module.labels.tags


  vpc_config {
    security_group_ids      = [join("", aws_security_group.default.*.id)]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
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


  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
    aws_cloudwatch_log_group.default

  ]
}


# Enabling IAM Roles for Service Accounts in Kubernetes cluster
#
# From official docs:
# The IAM roles for service accounts feature is available on new Amazon EKS Kubernetes version 1.14 clusters,
# and clusters that were updated to versions 1.14 or 1.13 on or after September 3rd, 2019.
#
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# https://medium.com/@marcincuber/amazon-eks-with-oidc-provider-iam-roles-for-kubernetes-services-accounts-59015d15cb0c
#
resource "aws_iam_openid_connect_provider" "default" {
  count = (var.enabled && var.oidc_provider_enabled) ? 1 : 0
  url   = join("", aws_eks_cluster.default.*.identity.0.oidc.0.issuer)

  client_id_list = ["sts.amazonaws.com"]

  # it's thumbprint won't change for many years
  # https://github.com/terraform-providers/terraform-provider-aws/issues/10104
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}