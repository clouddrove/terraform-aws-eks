################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_iam_role" {
  description = "ARN of cluster IAM role"
  value       = module.eks.cluster_iam_role_name
}

output "node_group_iam_role" {
  description = "ARN of node group IAM role"
  value       = module.eks.node_group_iam_role_name
}

output "capabilities" {
  description = "Map of attribute maps for all EKS Capabilities created"
  value       = module.eks.capabilities
}

output "capabilities_iam_role_arns" {
  description = "Map of IAM role ARNs used by each EKS Capability"
  value       = module.eks.capabilities_iam_role_arns
}

output "argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = try(module.eks.capabilities["argocd"].configuration[0].argo_cd[0].server_url, null)
}