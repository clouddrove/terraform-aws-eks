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

module "eks-cluster" {
  source = "../../"

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
  ## Ec2
  on_demand_enabled = false
  key_name          = module.keypair.name
  image_id          = "ami-0ceab0713d94f9276"
  instance_type     = "t3.small"
  max_size          = 3
  min_size          = 1
  volume_size       = 20

  ## Spot
  spot_enabled  = true
  spot_max_size = 3
  spot_min_size = 1

  max_price                   = "0.20"
  spot_instance_type          = "m5.large"
  associate_public_ip_address = true

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true
  kubernetes_version        = "1.17"
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