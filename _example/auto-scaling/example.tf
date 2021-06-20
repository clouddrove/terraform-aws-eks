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

  key_path        = "~/.ssh/id_rsa.pub"
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

  spot_schedule_enabled            = false
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
  node_group_enabled = true
  node_groups = {
    tools = {
      node_group_name           = "autoscale"
      subnet_ids                = module.subnets.private_subnet_id
      ami_type                  = "AL2_x86_64"
      node_group_volume_size    = 100
      node_group_instance_types = ["t3.large"]
      kubernetes_labels         = {}
      kubernetes_version        = "1.20"
      node_group_desired_size   = 1
      node_group_max_size       = 1
      node_group_min_size       = 1
      node_group_capacity_type  = "ON_DEMAND"
      node_group_volume_type    = "gp2"
    }
  }


  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true
  kubernetes_version        = "1.20"
  map_additional_iam_users = [
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
