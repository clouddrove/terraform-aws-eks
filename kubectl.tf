# If you want to automatically apply the Kubernetes configuration, set `var.apply_config_map_aws_auth` to "true"

locals {
  kubeconfig_filename = "_config/kubeconfig${var.delimiter}${module.eks_cluster.eks_cluster_id}.yaml"
}

resource "local_file" "kubeconfig" {
  count    = var.enabled || var.apply_config_map_aws_auth ? 1 : 0
  content  = module.eks_cluster.kubeconfig
  filename = local.kubeconfig_filename
}
