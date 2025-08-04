output "eks_cluster_status" {
  value = data.aws_eks_cluster.this.status
}

output "eks_cluster_name" {
  value = data.aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  value = data.aws_eks_cluster.this.endpoint
}