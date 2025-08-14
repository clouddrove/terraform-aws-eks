output "node_group_role_arn" {
  description = "ARN of the IAM role assigned to the EKS managed node group."
  value       = module.node-group-role.arn
}

output "node_group_role_name" {
  description = "Name of the IAM role assigned to the EKS managed node group."
  value       = module.node-group-role.name
}