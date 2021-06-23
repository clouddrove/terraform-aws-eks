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
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  extra_tags  = local.node_group_tags
  attributes  = compact(concat(var.attributes, ["node-group"]))
  label_order = var.label_order
}


#Module:     : NODE GROUP
#Description : Creating a node group for eks cluster
resource "aws_eks_node_group" "default" {
  for_each        = var.node_groups
  cluster_name    = var.cluster_name
  node_group_name = each.value.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = each.value.subnet_ids
  instance_types  = each.value.node_group_instance_types
  labels          = each.value.kubernetes_labels
  release_version = var.ami_release_version
  version         = each.value.kubernetes_version
  tags            = module.labels.tags
  capacity_type   = each.value.node_group_capacity_type

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
