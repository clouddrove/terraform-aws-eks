
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
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary = var.permissions_boundary

  tags = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSClusterPolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.default[0].name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEKSServicePolicy", data.aws_partition.current.partition)
  role       = aws_iam_role.default[0].name
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
  role   = aws_iam_role.default[0].name
  policy = data.aws_iam_policy_document.service_role[0].json

  name = module.labels.id

}


#-------------------------------------------------------IAM FOR node Group----------------------------------------------

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "node_groups" {
  count              = var.enabled ? 1 : 0
  name               = "${module.labels.id}-node_group"
  assume_role_policy = data.aws_iam_policy_document.node_group[0].json
  tags               = module.labels.tags
}

#Module      : IAM ROLE POLICY ATTACHMENT CNI
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if var.enabled }

  policy_arn = each.value
  role       = aws_iam_role.node_groups[0].name
}

#Module      : IAM ROLE POLICY ATTACHMENT EC2 CONTAINER REGISTRY READ ONLY
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy[0].json
}

resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.amazon_eks_node_group_autoscaler_policy[0].arn
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_policy" "amazon_eks_worker_node_autoscaler_policy" {
  count  = var.enabled ? 1 : 0
  name   = "${module.labels.id}-autoscaler"
  path   = "/"
  policy = data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy[0].json
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_autoscaler_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.amazon_eks_worker_node_autoscaler_policy[0].arn
  role       = aws_iam_role.node_groups[0].name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKSWorkerNodePolicy")
  role       = aws_iam_role.node_groups[0].name
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
      "ec2:DescribeLaunchTemplateVersions",
      "ecr:*"
    ]
    resources = ["*"]
  }
}

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = var.enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = aws_iam_role.node_groups[0].name
}