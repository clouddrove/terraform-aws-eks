output "kubeconfig" {
  value       = join("", data.template_file.kubeconfig.*.rendered)
  description = "`kubeconfig` configuration to connect to the cluster using `kubectl`. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#configuring-kubectl-for-eks."
}

output "security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "ID of the EKS cluster Security Group."
}

output "security_group_arn" {
  value       = join("", aws_security_group.default.*.arn)
  description = "ARN of the EKS cluster Security Group."
}

output "security_group_name" {
  value       = join("", aws_security_group.default.*.name)
  description = "Name of the EKS cluster Security Group."
}

output "eks_cluster_id" {
  value       = join("", aws_eks_cluster.default.*.id)
  description = "The name of the cluster."
}

output "eks_cluster_arn" {
  value       = join("", aws_eks_cluster.default.*.arn)
  description = "The Amazon Resource Name (ARN) of the cluster."
}

output "eks_cluster_certificate_authority_data" {
  value       = local.certificate_authority_data
  description = "The base64 encoded certificate data required to communicate with the cluster."
}

output "eks_cluster_endpoint" {
  value       = join("", aws_eks_cluster.default.*.endpoint)
  description = "The endpoint for the Kubernetes API server."
}

output "eks_cluster_version" {
  value       = join("", aws_eks_cluster.default.*.version)
  description = "The Kubernetes server version of the cluster."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}

output "cluster_security_group_id" {
  value       = join("", aws_eks_cluster.default.*.vpc_config.0.cluster_security_group_id)
  description = "The cluster security group that was created by Amazon EKS for the cluster."
}

output "kubernetes_config_map_id" {
  description = "ID of `aws-auth` Kubernetes ConfigMap"
  value       = var.kubernetes_config_map_ignore_role_changes ? join("", kubernetes_config_map.aws_auth_ignore_changes.*.id) : join("", kubernetes_config_map.aws_auth.*.id)
}
