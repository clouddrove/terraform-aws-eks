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
  associate_public_ip_address         = false
  key_name                            = module.keypair.name

  ## volume_size
  volume_size = 20

  ## ondemand
  ondemand_enabled          = true
  ondemand_instance_type    = ["t3.small", "t3.medium", "t3.small"]
  ondemand_max_size         = [1, 0, 0]
  ondemand_min_size         = [1, 0, 0]
  ondemand_desired_capacity = [1, 0, 0]

  ondemand_schedule_enabled            = false
  ondemand_schedule_max_size_scaleup   = [0, 0, 0]
  ondemand_schedule_desired_scaleup    = [0, 0, 0]
  ondemand_schedule_min_size_scaleup   = [0, 0, 0]
  ondemand_schedule_min_size_scaledown = [0, 0, 0]
  ondemand_schedule_max_size_scaledown = [0, 0, 0]
  ondemand_schedule_desired_scale_down = [0, 0, 0]


  ## Spot
  spot_enabled          = true
  spot_instance_type    = ["t3.small", "t3.medium", "t3.small"]
  spot_max_size         = [1, 0, 0]
  spot_min_size         = [1, 0, 0]
  spot_desired_capacity = [1, 0, 0]
  max_price             = ["0.20", "0.20", "0.20"]

  spot_schedule_enabled            = true
  spot_schedule_min_size_scaledown = [0, 0, 0]
  spot_schedule_max_size_scaledown = [0, 0, 0]
  spot_schedule_desired_scale_down = [0, 0, 0]
  spot_schedule_desired_scaleup    = [0, 0, 0]
  spot_schedule_max_size_scaleup   = [0, 0, 0]
  spot_schedule_min_size_scaleup   = [0, 0, 0]

  ## Schedule time
  scheduler_down = "0 19 * * MON-FRI"
  scheduler_up   = "0 6 * * MON-FRI"

  #node_group
  node_group_enabled              = false
  node_group_name                 = ["tools", "api"]
  node_group_instance_types       = ["t3.small", "t3.medium"]
  node_group_min_size             = [1, 1]
  node_group_desired_size         = [1, 1]
  node_group_max_size             = [2, 2]
  node_group_volume_size          = 20
  before_cluster_joining_userdata = ""
  node_group_capacity_type        = "ON_DEMAND"


  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true
  kubernetes_version        = "1.18"
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


  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"

  ## EBS Encryption
  ebs_encryption = true

  ## logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}