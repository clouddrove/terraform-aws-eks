locals {
  # Encryption
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled ? aws_kms_key.cluster[0].arn : null
  }
  aws_policy_prefix             = format("arn:%s:iam::aws:policy", data.aws_partition.current[0].partition)
  create_outposts_local_cluster = length(var.outpost_config) > 0

}
