## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
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

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
}

#Module      : IAM ROLE POLICY ATTACHMENT CLUSTER
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default[0].name
}

#Module      : IAM ROLE POLICY ATTACHMENT SERVICE
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = join("", aws_iam_role.default.*.name)
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

#Module      : KMS 
#Description : KMS security key for eks cluster
module "kms_key" {
    source      = "git::https://github.com/aashishgoyal246/terraform-aws-kms.git?ref=slave"
    
    name        = var.name
    application = var.application
    environment = var.environment
    managedby   = var.managedby
    label_order = var.label_order
    enabled     = var.enabled
    
    description              = "KMS key for cloudtrail"
    alias                    = var.alias
    key_usage                = var.key_usage
    customer_master_key_spec = var.customer_master_key_spec
    deletion_window_in_days  = var.deletion_window_in_days
    is_enabled               = var.is_enabled
    enable_key_rotation      = var.enable_key_rotation
    policy                   = data.aws_iam_policy_document.default.json
    tags                     = module.labels.tags
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
      "${var.aws_account_id}"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
  }
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

  encryption_config {
    provider {
      key_arn = module.kms_key.key_arn
    }
    resources = var.resources
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy,
  ]
}

locals {
  certificate_authority_data_list = coalescelist(
    aws_eks_cluster.default.*.certificate_authority,
    [
      [
        {
          "data" = ""
        },
      ],
    ],
  )
  certificate_authority_data_list_internal = local.certificate_authority_data_list[0]
  certificate_authority_data_map           = local.certificate_authority_data_list_internal[0]
  certificate_authority_data               = local.certificate_authority_data_map["data"]
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