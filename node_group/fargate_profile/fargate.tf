terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.1.15"
    }
  }
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["fargate"]))
  label_order = var.label_order
}


#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "fargate_role" {
  count = var.enabled && var.fargate_enabled ? 1 : 0

  name               = format("%s-fargate-role", module.labels.id)
  assume_role_policy = data.aws_iam_policy_document.aws_eks_fargate_policy[0].json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pod_execution_role_policy" {
  count = var.enabled && var.fargate_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_role[0].name
}

#Module      : EKS Fargate
#Descirption : Enabling fargate for AWS EKS
resource "aws_eks_fargate_profile" "default" {
  for_each = var.enabled && var.fargate_enabled ? var.fargate_profiles : {}

  cluster_name           = var.cluster_name
  fargate_profile_name   = format("%s-%s", module.labels.id, each.value.addon_name)
  pod_execution_role_arn = aws_iam_role.fargate_role[0].arn
  subnet_ids             = var.subnet_ids
  tags                   = module.labels.tags

  selector {
    namespace = lookup(each.value, "namespace", "default")
    labels    = lookup(each.value, "labels", null)
  }
}

# AWS EKS Fargate policy
data "aws_iam_policy_document" "aws_eks_fargate_policy" {
  count = var.enabled && var.fargate_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
