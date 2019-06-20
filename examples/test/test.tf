provider "aws" {
  region = "eu-west-1"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit','XYZ')"
}

locals {
  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = "${merge(var.tags, map("kubernetes.io/cluster/eg-testing-cluster", "shared"))}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "eg"
  stage      = "testing"
  name       = "cluster"
  tags       = "${local.tags}"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  namespace           = "eg"
  stage               = "testing"
  name                = "cluster"
  tags                = "${local.tags}"
  region              = "eu-west-1"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "eks_cluster" {
  source     = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=master"
  namespace  = "eg"
  stage      = "testing"
  name       = "cluster"
  tags       = "${var.tags}"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.subnets.public_subnet_ids}"]

  # `workers_security_group_count` is needed to prevent `count can't be computed` errors
  workers_security_group_ids   = ["${module.eks_workers.security_group_id}"]
  workers_security_group_count = 1
}

module "eks_workers" {
  source        = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=master"
  namespace     = "eg"
  stage         = "testing"
  name          = "cluster"
  tags          = "${var.tags}"
  instance_type = "t2.nano"
  vpc_id        = "${module.vpc.vpc_id}"

  subnet_ids = [
    "${module.subnets.public_subnet_ids}",
  ]

  health_check_type                  = "EC2"
  min_size                           = 1
  max_size                           = 3
  wait_for_capacity_timeout          = "10m"
  associate_public_ip_address        = true
  cluster_name                       = "eg-testing-cluster"
  cluster_endpoint                   = "${module.eks_cluster.eks_cluster_endpoint}"
  cluster_certificate_authority_data = "${module.eks_cluster.eks_cluster_certificate_authority_data}"
  cluster_security_group_id          = "${module.eks_cluster.security_group_id}"

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "80"
  cpu_utilization_low_threshold_percent  = "20"
}
