locals {
  aws_policy_prefix = format("arn:%s:iam::aws:policy", join("", data.aws_partition.current.*.partition))
  enabled           = var.enabled ? true : false
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.labels.tags
}

#Module      : IAM ROLE POLICY ATTACHMENT CNI
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.default.*.name)
}

#Module      : IAM ROLE POLICY ATTACHMENT EC2 CONTAINER REGISTRY READ ONLY
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_node_group_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_policy" "amazon_eks_worker_node_autoscaler_policy" {
  count  = local.enabled ? 1 : 0
  name   = "${module.labels.id}-autoscaler"
  path   = "/"
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_autoscaler_policy" {
  count      = local.enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_worker_node_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = local.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKSWorkerNodePolicy")
  role       = join("", aws_iam_role.default.*.name)
}

data "aws_iam_policy_document" "assume_role" {
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

# Autoscaler policy for node group
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
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}
#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "ecr" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-ecr-policy", module.labels.id)
  policy = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:*",
      "cloudtrail:LookupEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecr" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = join("", aws_iam_policy.ecr.*.arn)
}

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = var.enabled || var.ondemand_enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.default.*.name)
}
