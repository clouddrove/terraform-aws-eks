

output "eks_node_group_id" {
  value       = { for p in sort(keys(var.node_groups)) : p => aws_eks_node_group.default[p].id }
  description = "EKS Cluster name and EKS Node Group name separated by a colon"
}

output "eks_node_group_arn" {
  value       = { for p in sort(keys(var.node_groups)) : p => aws_eks_node_group.default[p].arn }
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
}

output "eks_node_group_resources" {
  value       = { for p in sort(keys(var.node_groups)) : p => aws_eks_node_group.default[p].resources }
  description = "List of objects containing information about underlying resources of the EKS Node Group"
}

output "eks_node_group_status" {
  value       = { for p in sort(keys(var.node_groups)) : p => aws_eks_node_group.default[p].status }
  description = "Status of the EKS Node Group"
}
