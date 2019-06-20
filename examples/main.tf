provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.11.0"
  name        = "${var.name}"
  application = "${var.application}"
  environment = "${var.environment}"
  cidr_block  = "${var.vpc_cidr_block}"
}

module "subnet" {
  source = "../../aws/terraform-aws-pub-pri-subnet"

  name        = "${var.name}"
  application = "clouddrove"
  environment = "test"
  availability_zones = ["${var.availability_zones}",]

  vpc_id      = "${module.vpc.vpc_id}"
  igw_id      = "${module.vpc.igw_id}"
  cidr_block  = "${module.vpc.vpc_cidr_block}"
  type        = "public-private"
}

module "eks-cluster" {
  source = "../../terraform-aws-eks-cluster"

  //source = "https://github.com/clouddrove/terraform-aws-eks-cluster"

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
  key_name                    = ""
  image_id                    = "ami-0abcb9f9190e867ab"
  instance_type               = "t2.nano"
  max_size                    = "1"
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
  vpc_id                                 = "${module.vpc.vpc_id}"
  subnet_ids                             = ["${module.subnet.public_subnet_id}"]
}
