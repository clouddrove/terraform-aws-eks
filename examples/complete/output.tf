output "eks_name" {
  value = module.eks.cluster_id
}

output "node_iam_role_name" {
  value = module.eks.node_group_iam_role_name
}

output "tags" {
  value = module.eks.tags
}