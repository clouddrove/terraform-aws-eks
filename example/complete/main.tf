provider "aws" {
  region = "eu-west-1"
}
locals {
  tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
  }
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.0"

  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

################################################################################
# Subnets
################################################################################

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  name        = "subnets"
  environment = "test"
  label_order = ["environment", "name"]
  tags        = local.tags
  enabled     = true

  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
}

################################################################################
# Keypair
################################################################################

module "keypair" {
  source  = "clouddrove/keypair/aws"
  version = "1.3.0"

  name        = "key"
  environment = "test"
  label_order = ["name", "environment"]

  enable_key_pair = true
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDc4AjHFctUATtd5of4u9bJtTgkh9bKogSDjxc9QqbylRORxUa422jO+t1ldTVdyqDRKltxQCJb4v23HZc2kssU5uROxpiF2fzgiHXRduL+RtyOtY2J+rNUdCRmHz4WQySblYpgteIJZpVo2smwdek8xSpjoHXhgxxa9hb4pQQwyjtVGEdH8vdYwtxgPZgPVaJgHVeJgVmhjTf2VGTATaeR9txzHsEPxhe/n1y34mQjX0ygEX8x0RZzlGziD1ih3KPaIHcpTVSYYk4LOoMK38vEI67SIMomskKn4yU043s+t9ZriJwk2V9+oU6tJU/5E1rd0SskXUhTypc3/Znc/rkYtLe8s6Uy26LOrBFzlhnCT7YH1XbCv3rEO+Nn184T4BSHeW2up8UJ1SOEd+WzzynXczdXoQcBN2kaz4dYFpRXchsAB6ejZrbEq7wyZvutf11OiS21XQ67+30lEL2WAO4i95e4sI8AdgwJgzrqVcicr3ImE+BRDkndMn5k1LhNGqwMD3Iuoel84xvinPAcElDLiFmL3BJVA/53bAlUmWqvUGW9SL5JpLUmZgE6kp+Tps7D9jpooGGJKmqgJLkJTzAmTSJh0gea/rT5KwI4j169TQD9xl6wFqns4BdQ4dMKHQCgDx8LbEd96l9F9ruWwQ8EAZBe4nIEKTV9ri+04JVhSQ== hello@clouddrove.com"
}

################################################################################
# SSH
################################################################################

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"

  name        = "ssh"
  environment = "test"
  label_order = ["environment", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../.."

  name        = "eks"
  environment = "test"
  label_order = ["environment", "name"]
  enabled     = true

  kubernetes_version        = "1.21"
  endpoint_private_access   = true
  endpoint_public_access    = false
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  oidc_provider_enabled     = true

  # Networking
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.subnets.private_subnet_id
  allowed_security_groups = [module.ssh.security_group_ids]
  allowed_cidr_blocks     = ["10.0.0.0/16"]

  ################################################################################
  # Self Managed Node Group
  ################################################################################
  # Node Groups Defaults Values It will Work all Node Groups
  self_node_group_defaults = {
    subnet_ids = module.subnets.private_subnet_id
    key_name   = module.keypair.name
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
    tools = {
      name                 = "tools"
      min_size             = 1
      max_size             = 7
      desired_size         = 2
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"
      instance_type        = "t4g.medium"
    }

    spot = {
      name = "spot"
      instance_market_options = {
        market_type = "spot"
      }
      min_size             = 1
      max_size             = 7
      desired_size         = 1
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      instance_type        = "t4g.medium"
    }
    # Schdule EKS Managed Auto Scaling node group
    schedules = {
      scale-up = {
        min_size     = 2
        max_size     = 2 # Retains current max size
        desired_size = 2
        start_time   = "2023-05-15T19:00:00Z"
        end_time     = "2023-05-19T19:00:00Z"
        timezone     = "Europe/Amsterdam"
        recurrence   = "0 7 * * 1"
      },
      scale-down = {
        min_size     = 0
        max_size     = 0 # Retains current max size
        desired_size = 0
        start_time   = "2023-05-12T12:00:00Z"
        end_time     = "2024-03-05T12:00:00Z"
        timezone     = "Europe/Amsterdam"
        recurrence   = "0 7 * * 5"
      }
    }

  }


  ################################################################################
  # AWS Managed Node Group
  ################################################################################
  # Node Groups Defaults Values It will Work all Node Groups
  managed_node_group_defaults = {
    subnet_ids                          = module.subnets.private_subnet_id
    key_name                            = module.keypair.name
    nodes_additional_security_group_ids = [module.ssh.security_group_ids]
    tags = {
      Example = "test"
    }

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

  managed_node_group = {
    test = {
      min_size       = 1
      max_size       = 7
      desired_size   = 2
      instance_types = ["t4g.medium"]
    }

    spot = {
      name          = "spot"
      capacity_type = "SPOT"

      min_size             = 1
      max_size             = 7
      desired_size         = 1
      force_update_version = true
      instance_types       = ["t4g.medium"]
    }
  }

  apply_config_map_aws_auth = true
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::924144197303:user/hello@clouddrove.com"
      username = "hello@clouddrove.com"
      groups   = ["system:masters"]
    }
  ]
  # Schdule EKS Managed Auto Scaling node group
  schedules = {
    scale-up = {
      min_size     = 2
      max_size     = 2 # Retains current max size
      desired_size = 2
      start_time   = "2023-05-15T19:00:00Z"
      end_time     = "2023-05-19T19:00:00Z"
      timezone     = "Europe/Amsterdam"
      recurrence   = "0 7 * * 1"
    },
    scale-down = {
      min_size     = 0
      max_size     = 0 # Retains current max size
      desired_size = 0
      start_time   = "2023-05-12T12:00:00Z"
      end_time     = "2024-03-05T12:00:00Z"
      timezone     = "Europe/Amsterdam"
      recurrence   = "0 7 * * 5"
    }
  }

}

################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_certificate_authority_data
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
