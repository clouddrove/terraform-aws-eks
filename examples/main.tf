module "subnets" {
  source = "../../terraform-aws-eks-cluster"

  name        = "eks"
  application = "clouddrove"
  environment = "test"
  enabled     = true

  version = "0.12"

  vpc_cidr_block = "10.0.0.0/16"

  key_name                    = ""
  image_id                    = ""
  instance_type               = "t2.nano"
  max_size                    = "1"
  min_size                    = "1"
  associate_public_ip_address = ""

  autoscaling_policies_enabled = ""

  allowed_cidr_blocks_cluster     = ""
  allowed_cidr_blocks_workers     = ""
  allowed_security_groups_workers = ""
  allowed_security_groups_cluster = ""
  wait_for_capacity_timeout       = ""
  apply_config_map_aws_auth       = ""

  availability_zones                     = "3"
  cpu_utilization_high_threshold_percent = "50"
  cpu_utilization_low_threshold_percent  = "10"
  health_check_type                      = ""
}
