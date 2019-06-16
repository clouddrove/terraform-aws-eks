module "subnets" {
  source = "../../terraform-aws-eks-cluster"

  //source = "https://github.com/clouddrove/terraform-aws-eks-cluster"

  ## Tags
  name        = "eks"
  application = "clouddrove"
  environment = "test"
  enabled     = true
  ## Network
  vpc_cidr_block                  = "10.0.0.0/16"
  allowed_security_groups_cluster = []
  allowed_security_groups_worker  = []
  ## Ec2
  key_name                    = ""
  image_id                    = ""
  instance_type               = "t2.nano"
  max_size                    = "1"
  min_size                    = "1"
  associate_public_ip_address = true
  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  ## Cluster
  version                   = "0.12"
  wait_for_capacity_timeout = "10m"
  apply_config_map_aws_auth = true
  ## Health Checks
  cpu_utilization_high_threshold_percent = "80"
  cpu_utilization_low_threshold_percent  = "20"
  health_check_type                      = "EC2"
}
