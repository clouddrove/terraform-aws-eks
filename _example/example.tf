provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source = "git::https://github.com/clouddrove/terraform-aws-keypair.git?ref=tags/0.12.1"

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

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.3"

  name        = "public-subnet"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}
module "ssh" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.2"

  name        = "ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["115.160.246.74/32"]
  allowed_ports = [22]
}

module "eks-cluster" {
  source = "./../"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "up"
  enabled     = true
  label_order = ["environment", "name"]

  ## Network
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnets.public_subnet_id
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = [module.ssh.security_group_ids]
  endpoint_private_access         = false
  endpoint_public_access          = true
  ## Ec2
  key_name      = module.keypair.name
  image_id      = "ami-0dd0a16a2bd0784b8"
  instance_type = "t3.small"
  max_size      = 3
  min_size      = 2
  volume_size   = 20

  associate_public_ip_address = true

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true
  kubernetes_version        = "1.14"

  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"

  #logs
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  #spot
  spot_enabled       = true
  spot_max_size      = 3
  spot_min_size      = 1
  max_price          = "0.50"
  spot_instance_type = "m5.large"
}