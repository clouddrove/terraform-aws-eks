output "arn" {
  value       = module.eks_cluster.*.eks_cluster_arn
  description = "The ARN of the certificate"
}

output "tags" {
  value       = module.eks_cluster.tags
  description = "A mapping of tags to assign to the certificate."
}