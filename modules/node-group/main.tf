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
  tags        = local.node_group_tags
  attributes  = compact(concat(var.attributes, ["node-group"]))
  label_order = var.label_order
}



#Module:     : NODE GROUP
#Description : Creating a node group for eks cluster
resource "aws_eks_node_group" "default" {
  count           = var.enabled && var.node_group_enabled ? 1 : 0
  cluster_name    = var.cluster_name
  node_group_name = module.labels.id
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.ami_type
  disk_size       = var.volume_size
  instance_types  = var.node_group_instance_types
  labels          = var.kubernetes_labels
  release_version = var.ami_release_version
  version         = var.kubernetes_version

  tags = module.labels.tags

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }
  dynamic "remote_access" {
    for_each = var.key_name != null && var.key_name != "" ? ["true"] : []
    content {
      ec2_ssh_key               = var.key_name
      source_security_group_ids = var.node_security_group_ids
    }
  }

  depends_on = [
    var.module_depends_on
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
