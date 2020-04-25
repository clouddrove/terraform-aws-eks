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
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.4"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=slave"

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
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.3"

  name        = "ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["49.36.129.154/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

module "kms_key" {
    source      = "git::https://github.com/aashishgoyal246/terraform-aws-kms.git?ref=slave"
    
    name        = "kms"
    application = "clouddrove"
    environment = "test"
    label_order = ["environment", "application", "name"]
    enabled     = true
    
    description              = "KMS key for cloudtrail"
    alias                    = "alias/cloudtrail"
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
  
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
      "${data.aws_caller_identity.current.account_id}"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
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
  fargate_enabled   = false     
  cluster_namespace = "kube-system"

  ## Node-Group
  node_group_enabled           = true
  number_of_node_groups        = 1
  desired_size                 = 2
  node_group_instance_types    = ["t3.medium"]
  
  ## Ec2
  autoscaling_policies_enabled = false
  key_name                     = module.keypair.name
  image_id                     = "ami-0ceab0713d94f9276"
  instance_type                = "t3.small"
  max_size                     = 3
  min_size                     = 1
  volume_size                  = 20
  kms_key_arn                  = module.kms_key.key_arn

  ## Spot
  spot_enabled  = true
  spot_max_size = 3
  spot_min_size = 1

  max_price                   = "0.20"
  spot_instance_type          = "m5.large"
  associate_public_ip_address = true

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = false
  kubernetes_version        = "1.15"

  ## Schedule
  scheduler_down = "0 19 * * MON-FRI"
  scheduler_up   = "0 6 * * MON-FRI"

  schedule_enabled   = true
  min_size_scaledown = 0
  max_size_scaledown = 1
  scale_up_desired   = 2
  scale_down_desired = 1

  spot_schedule_enabled   = true
  spot_min_size_scaledown = 0
  spot_max_size_scaledown = 1
  spot_scale_up_desired   = 2
  spot_scale_down_desired = 1

  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"

  ## EBS Encryption
  ebs_encryption = true
  
  ## logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}