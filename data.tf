data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "eks_cluster" {
  name   = try(aws_eks_cluster.default[0].name, var.cluster_name)
  region = try(var.region, data.aws_region.current.region)
}
data "aws_subnets" "eks" {
  filter {
    name   = "tag:kubernetes.io/cluster/${var.cluster_name}"
    values = ["owned", "shared"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id]
  }
}