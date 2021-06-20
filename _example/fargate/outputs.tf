output "arn" {
  value       = module.eks-cluster.*.eks_cluster_arn
  description = "The ARN of the certificate"
}

output "tags" {
  value       = module.eks-cluster.tags
  description = "A mapping of tags to assign to the certificate."
}
