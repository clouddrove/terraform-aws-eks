locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
  node_group_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/enabled" = "${var.node_group_enabled}"
    }
  )
  enabled = var.enabled ? true : false
  # Use a custom launch_template if one was passed as an input
  # Otherwise, use the default in this project
  userdata_vars = {
    before_cluster_joining_userdata = var.before_cluster_joining_userdata
  }
}

module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  tags        = local.tags
  attributes  = compact(concat(var.attributes, ["node-group"]))
  label_order = var.label_order
}

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
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

#Module      : IAM ROLE POLICY ATTACHMENT NODE
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled  ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled && var.node_group_enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}
data "aws_iam_policy_document" "amazon_eks_node_group_autoscaler_policy" {
  count = var.enabled && var.node_group_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}



resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled && var.node_group_enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_node_group_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.default.*.name)
}

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

resource "aws_iam_role_policy_attachment" "test-attach" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = join("", aws_iam_policy.ecr.*.arn)
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

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = var.enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.default.*.name)
}

#Module:     : NODE GROUP
#Description : Creating a node group for eks cluster
resource "aws_eks_node_group" "default" {
  for_each        = var.node_groups
  cluster_name    = var.cluster_name
  node_group_name = each.value.node_group_name
  node_role_arn   = join("", aws_iam_role.default.*.arn)
  subnet_ids      = each.value.subnet_ids
  instance_types  = each.value.node_group_instance_types
  labels          = each.value.kubernetes_labels
  release_version = var.ami_release_version
  version         = each.value.kubernetes_version
  tags            = module.labels.tags
  capacity_type   = each.value.node_group_capacity_type
  ami_type        = each.value.ami_type

  scaling_config {
    desired_size = each.value.node_group_desired_size
    max_size     = each.value.node_group_max_size
    min_size     = each.value.node_group_min_size
  }

  launch_template {
    name    = each.value.node_group_name
    version = 1
  }

  depends_on = [aws_launch_template.default]
}


resource "aws_launch_template" "default" {
  for_each = var.node_groups
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = each.value.node_group_volume_size
      volume_type = each.value.node_group_volume_type
      kms_key_id  = var.kms_key_arn
      encrypted   = var.ebs_encryption
    }
  }

  name                   = each.value.node_group_name
  update_default_version = true
  image_id               = var.ami_release_version
  key_name               = var.key_name

  dynamic "tag_specifications" {
    for_each = var.resources_to_tag
    content {
      resource_type = tag_specifications.value
      tags          = module.labels.tags
    }
  }

  vpc_security_group_ids = null
  user_data              = null
  tags                   = module.labels.tags
}
