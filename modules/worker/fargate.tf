#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "fargate_role" {
  count              = var.enabled && var.fargate_enabled ? 1 : 0
  name               = format("%s-fargate-role", module.labels.id)
  assume_role_policy = join("", data.aws_iam_policy_document.aws_eks_fargate_policy.*.json)
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pod_execution_role_policy" {
  count      = var.enabled && var.fargate_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = join("", aws_iam_role.fargate_role.*.name)
}

#Module      : EKS Fargate
#Descirption : Enabling fargate for AWS EKS
resource "aws_eks_fargate_profile" "default" {
  count                  = var.enabled && var.fargate_enabled ? 1 : 0
  cluster_name           = var.cluster_name
  fargate_profile_name   = format("%s-fargate-eks", module.labels.id)
  pod_execution_role_arn = join("", aws_iam_role.fargate_role.*.arn)
  subnet_ids             = var.subnet_ids
  tags                   = module.labels.tags

  selector {
    namespace = var.cluster_namespace
    labels    = var.kubernetes_labels
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
