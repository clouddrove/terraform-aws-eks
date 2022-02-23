output "cluster_arn" {
  value       = try(aws_eks_cluster.default[0].arn, "")
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "cluster_certificate_authority_data" {
  value       = try(aws_eks_cluster.default[0].certificate_authority[0].data, "")
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "cluster_endpoint" {
  value       = try(aws_eks_cluster.default[0].endpoint, "")
  description = "Endpoint for your Kubernetes API server"
}

output "cluster_id" {
  value       = try(aws_eks_cluster.default[0].id, "")
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
}

output "cluster_oidc_issuer_url" {
  value       = try(aws_eks_cluster.default[0].identity[0].oidc[0].issuer, "")
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
}

output "cluster_platform_version" {
  value       = try(aws_eks_cluster.default[0].platform_version, "")
  description = "Platform version for the cluster"
}

output "cluster_status" {
  value       = try(aws_eks_cluster.default[0].status, "")
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
}

output "cluster_primary_security_group_id" {
  value       = try(aws_eks_cluster.default[0].vpc_config[0].cluster_security_group_id, "")
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use default security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
}

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = try(aws_security_group.node_group[0].arn, "")
}

output "node_security_group_id" {
  value       = try(aws_security_group.node_group[0].id, "")
  description = "ID of the node shared security group"
}

output "oidc_provider_arn" {
  value       = try(aws_iam_openid_connect_provider.default[0].arn, "")
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
}

output "cluster_iam_role_name" {
  value       = try(aws_iam_role.default[0].name, "")
  description = "IAM role name of the EKS cluster"
}

output "cluster_iam_role_arn" {
  value       = try(aws_iam_role.default[0].arn, "")
  description = "IAM role ARN of the EKS cluster"
}

output "cluster_iam_role_unique_id" {
  value       = try(aws_iam_role.default[0].unique_id, "")
  description = "Stable and unique string identifying the IAM role"
}

output "node_group_iam_role_name" {
  value       = try(aws_iam_role.node_groups[0].name, "")
  description = "IAM role name of the EKS cluster"
}

output "node_group_iam_role_arn" {
  value       = try(aws_iam_role.node_groups[0].arn, "")
  description = "IAM role ARN of the EKS cluster"
}

output "node_group_iam_role_unique_id" {
  value       = try(aws_iam_role.node_groups[0].unique_id, "")
  description = "Stable and unique string identifying the IAM role"
}

output "tags" {
  value = module.labels.tags
}

output "cluster_name" {
  value = module.labels.id
}