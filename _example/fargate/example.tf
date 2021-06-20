locals {
  tags = {
    "kubernetes.io/cluster/test-eks-cluster" = "shared"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source  = "clouddrove/keypair/aws"
  version = "0.15.0"

  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfjNc4A+atuEBaElnpQqFkBFgGc+kCslpXh/aKETl1"
  key_name        = "main-key"
  enable_key_pair = true
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.0"

  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.15.0"

  name        = "subnets"
  environment = "test"
  label_order = ["environment", "name"]
  tags        = local.tags
  enabled     = true

  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
}

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "0.15.0"

  name        = "ssh"
  environment = "test"
  label_order = ["environment", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["49.36.129.154/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

module "eks-cluster" {
  source = "../../"

  ## Tags
  name        = "eks"
  environment = "test"
  label_order = ["environment", "name"]
  enabled     = true

  ## Network
  vpc_id                              = module.vpc.vpc_id
  eks_subnet_ids                      = module.subnets.public_subnet_id
  worker_subnet_ids                   = module.subnets.private_subnet_id
  allowed_security_groups_cluster     = []
  allowed_security_groups_workers     = []
  additional_security_group_ids       = [module.ssh.security_group_ids]
  endpoint_private_access             = false
  endpoint_public_access              = true
  public_access_cidrs                 = ["0.0.0.0/0"]
  cluster_encryption_config_resources = ["secrets"]

  ## EKS Fargate
  fargate_enabled   = true
  cluster_namespace = "kube-system"

  ## Cluster
  kubernetes_version = "1.20"
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::924144197303:user/rishabh@clouddrove.com"
      username = "rishabh@clouddrove.com"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::924144197303:user/nikita@clouddrove.com"
      username = "nikita@clouddrove.com"
      groups   = ["system:masters"]
    }

  ]

  ## logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
# Ensure ordering of resource creation to eliminate the race conditions when applying the Kubernetes Auth ConfigMap.
# Do not create Node Group before the EKS cluster is created and the `aws-auth` Kubernetes ConfigMap is applied.
# Otherwise, EKS will create the ConfigMap first and add the managed node role ARNs to it,
# and the kubernetes provider will throw an error that the ConfigMap already exists (because it can't update the map, only create it).
# If we create the ConfigMap first (to add additional roles/users/accounts), EKS will just update it by adding the managed node role ARNs.
data "null_data_source" "wait_for_cluster_and_kubernetes_configmap" {
  inputs = {
    cluster_name             = module.eks-cluster.eks_cluster_id
    kubernetes_config_map_id = module.eks-cluster.kubernetes_config_map_id
  }
}
