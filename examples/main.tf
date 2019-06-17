provider "aws" {
  region = "us-east-1"
}

module "subnets" {
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
  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  ## Cluster
  wait_for_capacity_timeout = "15m"
  apply_config_map_aws_auth = "true"
  ## Health Checks
  cpu_utilization_high_threshold_percent = "80"
  cpu_utilization_low_threshold_percent  = "20"
  health_check_type                      = "EC2"
}
