locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

#   enabled = var.enabled ? true : false
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  tags        = local.tags
  attributes  = compact(concat(var.attributes, ["cluster"]))
  label_order = var.label_order
}



resource "aws_eks_node_group" "node_group" {
count             = "${length(var.node_groups)}"
  cluster_name  =  module.labels.id
  node_group_name = "${element(var.node_groups,count.index)}"
  node_role_arn = var.aws_iam_role_arn  
  subnet_ids    = var.subnet_ids
  disk_size    = "${element(var.disk_size,count.index)}"
  instance_types  = "${element(var.instance_types,count.index)}"

  remote_access {
      ec2_ssh_key               = var.key_name
      source_security_group_ids = var.workers_security_group_id
    }
  scaling_config {
    desired_size = "${element(var.desired_size,count.index)}"
    max_size     = "${element(var.max_size,count.index)}"
    min_size     = "${element(var.min_size,count.index)}"
  }
    
    tags        = module.labels.tags
  
  }
