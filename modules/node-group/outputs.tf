

output "eks_node_group_id" {
  value       = join("", aws_eks_node_group.default.*.id)
  description = "EKS Cluster name and EKS Node Group name separated by a colon"
}

output "eks_node_group_arn" {
  value       = join("", aws_eks_node_group.default.*.arn)
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
}

output "eks_node_group_resources" {
  value       = var.enabled ? aws_eks_node_group.default.*.resources : []
  description = "List of objects containing information about underlying resources of the EKS Node Group"
}

output "eks_node_group_status" {
  value       = join("", aws_eks_node_group.default.*.status)
  description = "Status of the EKS Node Group"
}