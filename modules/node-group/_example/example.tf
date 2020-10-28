locals {
  tags = {
    "kubernetes.io/cluster/${module.eks_cluster.eks_cluster_id}" = "shared"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source = "git::https://github.com/clouddrove/terraform-aws-keypair.git?ref=tags/0.12.2"

  key_path        = "~/.ssh/id_rsa.pub"
  key_name        = "main-key"
  enable_key_pair = true
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.5"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.6"

  name        = "subnets"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  tags        = local.tags
  enabled     = true

  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
}

module "ssh" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.4"

  name        = "ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["49.36.129.154/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

module "kms_key" {
  source = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/0.12.5"

  name        = "kms"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  description              = "KMS key for eks"
  alias                    = "alias/eks"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  is_enabled               = true
  enable_key_rotation      = false
  policy                   = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "eks_cluster" {
  source = "git::https://github.com/clouddrove/terraform-aws-eks.git"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
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
  apply_config_map_aws_auth           = true
  ## Cluster
  kubernetes_version = "1.17"
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
  #kms_key_arn        = module.kms_key.key_arn

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
    cluster_name             = module.eks_cluster.eks_cluster_id
    kubernetes_config_map_id = module.eks_cluster.kubernetes_config_map_id
  }
}

#Module      : EKS node_group
#Description : Manages an EKS Autoscaling.
module "node_group" {
  source = "./../"

  ## Tags
  name                            = "eks"
  application                     = "clouddrove"
  environment                     = "test"
  label_order                     = ["environment", "application", "name"]
  enabled                         = true
  cluster_name                    = module.eks_cluster.eks_cluster_id
  node_group_desired_size         = 1
  node_group_max_size             = 3
  node_group_min_size             = 1
  node_group_enabled              = true
  subnet_ids                      = module.subnets.private_subnet_id
  key_name                        = module.keypair.name
  kubernetes_version              = "1.17"
  volume_size                     = 20
  node_security_group_ids         = []
  node_group_instance_types       = ["t2.small"]
  before_cluster_joining_userdata = ""
  node_role_arn                   = module.eks_cluster.iam_role_arn
  module_depends_on               = module.eks_cluster
}
