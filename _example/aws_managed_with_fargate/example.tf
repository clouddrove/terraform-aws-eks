provider "aws" {
  region = local.region
}

locals {
  name           = "clouddrove-eks"
  region         = "eu-west-1"
  vpc_cidr_block = module.vpc.vpc_cidr_block
  environment    = "test"
  label_order    = ["name", "environment"]
  tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "owned"
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

# ################################################################################
# # Subnets moudle call
# ################################################################################

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name                = "${local.name}-subnet"
  environment         = local.environment
  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = local.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  enable_ipv6         = false

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

################################################################################
# Keypair module call
################################################################################
module "keypair" {
  source  = "clouddrove/keypair/aws"
  version = "1.3.0"

  name            = "${local.name}-key"
  environment     = local.environment
  label_order     = local.label_order
  enable_key_pair = true
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDc4AjHFctUATtd5of4u9bJtTgkh9bKogSDjxc9QqbylRORxUa422jO+t1ldTVdyqDRKltxQCJb4v23HZc2kssU5uROxpiF2fzgiHXRduL+RtyOtY2J+rNUdCRmHz4WQySblYpgteIJZpVo2smwdek8xSpjoHXhgxxa9hb4pQQwyjtVGEdH8vdYwtxgPZgPVaJgHVeJgVmhjTf2VGTATaeR9txzHsEPxhe/n1y34mQjX0ygEX8x0RZzlGziD1ih3KPaIHcpTVSYYk4LOoMK38vEI67SIMomskKn4yU043s+t9ZriJwk2V9+oU6tJU/5E1rd0SskXUhTypc3/Znc/rkYtLe8s6Uy26LOrBFzlhnCT7YH1XbCv3rEO+Nn184T4BSHeW2up8UJ1SOEd+WzzynXczdXoQcBN2kaz4dYFpRXchsAB6ejZrbEq7wyZvutf11OiS21XQ67+30lEL2WAO4i95e4sI8AdgwJgzrqVcicr3ImE+BRDkndMn5k1LhNGqwMD3Iuoel84xvinPAcElDLiFmL3BJVA/53bAlUmWqvUGW9SL5JpLUmZgE6kp+Tps7D9jpooGGJKmqgJLkJTzAmTSJh0gea/rT5KwI4j169TQD9xl6wFqns4BdQ4dMKHQCgDx8LbEd96l9F9ruWwQ8EAZBe4nIEKTV9ri+04JVhSQ== hello@clouddrove.com"
}

# ################################################################################
# Security Groups module call
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
    cidr_blocks = [local.vpc_cidr_block, "172.16.0.0/16"]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow Mongodb traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, "172.16.0.0/16"]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow Mongodb outbound traffic."
  }]
}

module "http_https" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-http-https"
  environment = local.environment

  vpc_id = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = [local.vpc_cidr_block]
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
# KMS Module call
################################################################################
module "kms" {
  source  = "clouddrove/kms/aws"
  version = "1.3.0"

  name                = "${local.name}-kmss"
  environment         = local.environment
  label_order         = local.label_order
  enabled             = true
  description         = "KMS key for EBS of EKS nodes"
  enable_key_rotation = false
  policy              = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

}

################################################################################
# EKS Module call 
################################################################################
module "eks" {
  source  = "../.."
  enabled = true

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  # EKS
  kubernetes_version     = "1.27"
  endpoint_public_access = true
  # Networking
  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.subnets.private_subnet_id
  allowed_security_groups           = [module.ssh.security_group_id]
  eks_additional_security_group_ids = ["${module.ssh.security_group_id}", "${module.http_https.security_group_id}"]
  allowed_cidr_blocks               = ["10.0.0.0/16"]
  # AWS Managed Node Group
  # Node Groups Defaults Values It will Work all Node Groups
  managed_node_group_defaults = {
    subnet_ids                          = module.subnets.private_subnet_id
    key_name                            = module.keypair.name
    nodes_additional_security_group_ids = [module.ssh.security_group_id]
    tags = {
      "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
      "k8s.io/cluster/${module.eks.cluster_name}"        = "shared"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
          encrypted   = true
          kms_key_id  = module.kms.key_arn
        }
      }
    }
  }
  managed_node_group = {
    critical = {
      name           = "${module.eks.cluster_name}-critical"
      capacity_type  = "SPOT"
      min_size       = 1
      max_size       = 2
      desired_size   = 2
      instance_types = ["t3.medium"]
    }

    application = {
      name                 = "${module.eks.cluster_name}-application"
      capacity_type        = "SPOT"
      min_size             = 1
      max_size             = 2
      desired_size         = 1
      force_update_version = true
      instance_types       = ["t3.medium"]
    }
  }
  # -- Set this to `true` only when you have correct iam_user details.
  apply_config_map_aws_auth = true
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::123456789:user/hello@clouddrove.com"
      username = "hello@clouddrove.com"
      groups   = ["system:masters"]
    }
  ]
  #fargate profile
  fargate_enabled = true
  fargate_profiles = {
    profile-0 = {
      addon_name = "0"
      namespace  = "default"
    }
  }
}
## Kubernetes provider configuration
data "aws_eks_cluster" "this" {
  depends_on = [module.eks]
  name       = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [module.eks]
  name       = module.eks.cluster_certificate_authority_data
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
