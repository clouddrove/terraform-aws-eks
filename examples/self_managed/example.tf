provider "aws" {
  region = local.region
}
locals {
  name                  = "clouddrove-eks"
  region                = "eu-west-1"
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
  environment           = "test"
  label_order           = ["name", "environment"]
  tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
  }
}

################################################################################
# VPC module call
################################################################################
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "${local.name}-vpc"
  environment = local.environment
  cidr_block  = "10.10.0.0/16"
}

################################################################################
# Subnets
################################################################################
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name                = "${local.name}-subnets"
  environment         = local.environment
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

# ################################################################################
# Security Groups
################################################################################

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-ssh"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = [local.additional_cidr_block]
      description = "Allow Mongodb traffic."
    }
  ]
  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = [local.additional_cidr_block]
      description = "Allow Mongodb outbound traffic."
  }]
}

module "http_https" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-http-https"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "http"
      to_port     = 80
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "https"
      to_port     = 443
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Allow https traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
}

################################################################################
# EKS Module call
################################################################################
module "eks" {
  source = "../.."

  name        = local.name
  environment = "test"

  # EKS
  kubernetes_version      = "1.32"
  endpoint_private_access = true
  endpoint_public_access  = true
  # Networking
  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.subnets.private_subnet_id
  allowed_security_groups           = [module.ssh.security_group_id]
  eks_additional_security_group_ids = ["${module.ssh.security_group_id}", "${module.http_https.security_group_id}"]
  allowed_cidr_blocks               = [local.vpc_cidr_block]

  # Self Managed Node Grou
  # Node Groups Defaults Values It will Work all Node Groups
  self_node_group_defaults = {
    subnet_ids = module.subnets.private_subnet_id
    propagate_tags = [{
      key                 = "aws-node-termination-handler/managed"
      value               = true
      propagate_at_launch = true
      },
      {
        key                 = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
        value               = "owned"
        propagate_at_launch = true

      }
    ]

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
        }
      }
    }
  }

  self_node_groups = {
    critical = {
      name                 = "${module.eks.cluster_name}-critical"
      min_size             = 1
      max_size             = 7
      desired_size         = 1
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"
      instance_type        = "t3.medium"
    }
    application = {
      name = "${module.eks.cluster_name}-application"
      instance_market_options = {
        market_type = "spot"
      }
      min_size             = 1
      max_size             = 7
      desired_size         = 1
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      instance_type        = "t3.medium"
    }
  }
  # Schdule Self Managed Auto Scaling node group
  schedules = {
    scale-up = {
      min_size     = 2
      max_size     = 2 # Retains current max size
      desired_size = 2
      start_time   = "2023-08-15T19:00:00Z"
      end_time     = "2023-08-19T19:00:00Z"
      timezone     = "Europe/Amsterdam"
      recurrence   = "0 7 * * 1"
    },
    scale-down = {
      min_size     = 0
      max_size     = 0 # Retains current max size
      desired_size = 0
      start_time   = "2023-08-12T12:00:00Z"
      end_time     = "2024-03-05T12:00:00Z"
      timezone     = "Europe/Amsterdam"
      recurrence   = "0 7 * * 5"
    }
  }
}
# Kubernetes provider configuration
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_certificate_authority_data
}
#
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}