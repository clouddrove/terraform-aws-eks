provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "../../terraform-aws-vpc"
  name        = var.name
  application = var.application
  environment = var.environment
  cidr_block  = var.vpc_cidr_block
}

module "subnets" {
  source = "../../terraform-aws-subnet"

  name        = var.name
  application = var.application
  environment = var.environment

  availability_zones  = ["us-east-1b", "us-east-1c"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public"
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "false"
}

module "eks-cluster" {
  source = "./../"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  enabled     = "true"

  ## Network
  vpc_cidr_block                  = "10.0.0.0/16"
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = []

  ## Ec2
  key_name                    = "test"
  image_id                    = "ami-0200e65a38edfb7e1"
  instance_type               = "t2.small"
  max_size                    = "3"
  min_size                    = "1"
  associate_public_ip_address = "true"
  availability_zones          = ["us-east-1a", "us-east-1b"]

  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = "true"

  ## Health Checks
  cpu_utilization_high_threshold_percent = "80"
  cpu_utilization_low_threshold_percent  = "20"
  health_check_type                      = "EC2"
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = module.subnets.public_subnet_id
}

