data "aws_caller_identity" "current" {}

locals {
  tags = {
      "kubernetes.io/cluster/${module.eks-cluster.eks_cluster_id}" = "shared"
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
    source      = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/0.12.5"
    
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
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "eks-cluster" {
  source = "../../"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true


  ## Network
  vpc_id                          = module.vpc.vpc_id
  eks_subnet_ids                  = module.subnets.public_subnet_id
  worker_subnet_ids               = module.subnets.private_subnet_id
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = []
  additional_security_group_ids   = [module.ssh.security_group_ids]
  endpoint_private_access         = false
  endpoint_public_access          = true
  public_access_cidrs             = ["0.0.0.0/0"]
  resources                       = ["secrets"]

  ## EKS Fargate
  fargate_enabled   = true     
  cluster_namespace = "kube-system"

  ## Cluster
  kubernetes_version = "1.15"
  kms_key_arn        = module.kms_key.key_arn
  
  ## logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}