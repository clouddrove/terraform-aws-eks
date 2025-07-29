data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}
data "aws_subnets" "eks" {
  filter {
    name   = "tag:kubernetes.io/cluster/${cluster_name}"
    values = ["owned", "shared"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id]
  }
}