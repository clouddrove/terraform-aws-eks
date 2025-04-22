provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name            = "ex-${basename(path.cwd)}"
  cluster_version = "1.32"
  region          = "eu-west-1"

  vpc_cidr              = "10.0.0.0/16"
  environment           = "test"
  azs                   = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Test       = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

# ################################################################################
# Security Groups module call
################################################################################

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name   = "${local.name}-ssh"
  vpc_id = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr]
    description = "Allow ssh traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr]
    description = "Allow ssh outbound traffic."
  }]
}

module "http_https" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name   = "${local.name}-http-https"
  vpc_id = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = [local.vpc_cidr]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = [local.vpc_cidr]
      description = "Allow https traffic."
    }
  ]

  ## EGRESS Rules
  # tfsec:ignore:aws-vpc-no-public-egress-sgr
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = [local.vpc_cidr]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../.."

  name = "automode-auth"

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
    # node_role_arn = aws_iam_role.eks_auto[0].arn
  }

  enable_cluster_creator_admin_permissions = true

  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.vpc.private_subnets
  allowed_security_groups           = [module.ssh.security_group_id]
  eks_additional_security_group_ids = ["${module.ssh.security_group_id}", "${module.http_https.security_group_id}"]

  apply_config_map_aws_auth = false
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::XXXXXXXXXX:role/AWS_USERNAME"
      username = "AWS_USERNAME"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::XXXXXXXXXX:role/AWS_USERNAME"
      username = "AWS_USERNAME"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::XXXXXXXXXX:role/AWS_USERNAME"
      username = "AWS_USERNAME"
      groups   = ["system:masters"]
    }
  ]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name = local.name
  cidr_block = local.vpc_cidr

}


################################################################################
# Subnet Module
################################################################################
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name        = "${local.name}-subnets"
  environment = local.environment

  nat_gateway_enabled = true
  availability_zones  = ["${local.region}a", "${local.region}b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id

  extra_public_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }

  extra_private_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }

  public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]

  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]

  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]

  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}