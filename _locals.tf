locals {
  # Encryption
  cluster_encryption_config = {
    resources        = var.cluster_encryption_config_resources
    provider_key_arn = var.enabled ? join("", aws_kms_key.cluster.*.arn) : null
  }
  aws_policy_prefix = format("arn:%s:iam::aws:policy", join("", data.aws_partition.current.*.partition))

}



