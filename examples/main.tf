provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source      = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.11.0"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"

  cidr_block  = "10.0.0.0/16"
}

module "subnets"  {
  source              = "../../aws/terraform-aws-pub-pri-subnet"

  application        = "clouddrove"
  environment         = "test"
  name                = "subnet"

  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = "${module.vpc.vpc_id}"
  type                = "public-private"
  igw_id              = "${module.vpc.igw_id}"
  nat_gateway_enabled = "true"
  cidr_block    = "${module.vpc.vpc_cidr_block}"
}

module "eks_cluster" {
  source = "../../terraform-aws-eks-cluster"
  //source = "https://github.com/clouddrove/terraform-aws-eks-cluster"

  ## Tags
  name        = "eks-cluster"
  application = "clouddrove"
  environment = "dev"
  enabled     = "true"
  ## Network
  vpc_id                  = "${module.vpc.vpc_id}"
  subnet_ids              = ["${module.subnets.public_subnet_id}"]
  allowed_security_groups_cluster = []
  allowed_security_groups_workers = []
  ## Ec2
  key_name                    = ""
  image_id                    = "ami-08d658f84a6d84a80"
  instance_type               = "t2.nano"
  max_size                    = "1"
  min_size                    = "1"
  associate_public_ip_address = "true"
  availability_zones          = ["eu-west-1a", "eu-west-1b",]
  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = "true"
  ## Health Checks
  cpu_utilization_high_threshold_percent = "80"
  cpu_utilization_low_threshold_percent  = "20"
  health_check_type                      = "EC2"
}
