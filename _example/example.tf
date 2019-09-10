provider "aws" {
  region = "us-east-1"
}

module "keypair" {
  source = "git::https://github.com/clouddrove/terraform-aws-keypair.git?ref=tags/0.12.1"

  key_path        = "~/.ssh/id_rsa.pub"
  key_name        = "main-key"
  enable_key_pair = true
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.1"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.1"

  name        = "public-subnet"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  availability_zones = ["us-east-1b", "us-east-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
}


module "eks-cluster" {
  source = "git::https://github.com/clouddrove/terraform-aws-eks-cluster.git"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  enabled     = true

  ## Network
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnets.public_subnet_id
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = []

  ## Ec2
  key_name                    = module.keypair.name
  image_id                    = "ami-0200e65a38edfb7e1"
  instance_type               = "m5.large"
  max_size                    = 3
  min_size                    = 1
  associate_public_ip_address = true

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = true

  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"
}