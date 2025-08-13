output "node_group_role_arn" {
  description = "ARN of the IAM role assigned to the EKS managed node group."
  value       = module.node-group-role.arn
}

output "node_group_role_name" {
  description = "Name of the IAM role assigned to the EKS managed node group."
  value       = module.node-group-role.name
}
output "managed_node_group_security_group_ids" {
  description = "Security group IDs attached to the managed node groups."
  value       = module.eks.managed_node_group_security_group_ids
}