
# If you want to automatically apply the Kubernetes configuration, set `var.apply_config_map_aws_auth` to "true"

locals {
  kubeconfig_filename                 = "${path.module}/kubeconfig${var.delimiter}${module.eks_cluster.eks_cluster_id}.yaml"
  config_map_aws_auth_filename        = "${path.module}/config-map-aws-auth${var.delimiter}${module.eks_cluster.eks_cluster_id}.yaml"
  kubeconfig_filename_config          = "_config/kubeconfig${var.delimiter}${module.eks_cluster.eks_cluster_id}.yaml"
  config_map_aws_auth_filename_config = "_config/config-map-aws-auth${var.delimiter}${module.eks_cluster.eks_cluster_id}.yaml"
}

resource "local_file" "kubeconfig" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  content  = module.eks_cluster.kubeconfig
  filename = local.kubeconfig_filename
}

resource "local_file" "config_map_aws_auth" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  content  = module.eks_workers.config_map_aws_auth
  filename = local.config_map_aws_auth_filename
}

resource "local_file" "kubeconfig_config" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  content  = local.kubeconfig_filename
  filename = local.kubeconfig_filename_config
}

resource "local_file" "config_map_aws_auth_config" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  content  = local.config_map_aws_auth_filename
  filename = local.config_map_aws_auth_filename_config
}

resource "null_resource" "apply_config_map_aws_auth" {
  count = var.enabled && var.apply_config_map_aws_auth ? 1 : 0

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local.config_map_aws_auth_filename} --kubeconfig ${local.kubeconfig_filename}"
  }

  triggers = {
    kubeconfig_rendered          = module.eks_cluster.kubeconfig
    config_map_aws_auth_rendered = module.eks_workers.config_map_aws_auth
  }
}

