data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "eks_cluster" {
  name = try(aws_eks_cluster.default[0].name, var.cluster_name)
}
data "aws_subnets" "eks" {
  count = var.external_cluster ? 1 : 0
  filter {
    name   = var.subnet_filter_name
    values = var.subnet_filter_values
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id]
  }
}