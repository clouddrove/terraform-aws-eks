##--------------------------------------------------------------------
## LOCALS
##--------------------------------------------------------------------
locals {
  eks_cluster_name = "clouddrove-eks"
  region           = "us-east-1"
  environment      = "test"
}

##--------------------------------------------------------------------
## PROVIDERS
##--------------------------------------------------------------------
provider "aws" {
  region = local.region
}

# Kubernetes provider using the fetched cluster's details
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

##--------------------------------------------------------------------
## DATA SOURCES
##--------------------------------------------------------------------

# Fetch existing EKS cluster
data "aws_eks_cluster" "this" {
  name = local.eks_cluster_name
}

# Fetch authentication token for the EKS cluster
data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

data "aws_iam_policy_document" "default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "amazon_eks_node_group_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ecr:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}



##--------------------------------------------------------------------
## MODULE CALL
##--------------------------------------------------------------------

module "node-group-role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.2"

  name        = "${local.eks_cluster_name}-node-group"
  environment = local.environment

  # Allow EC2 to assume role
  assume_role_policy = data.aws_iam_policy_document.default.json
  policy             = data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.json

  # Attach managed policies required for EKS worker nodes
  policy_enabled = true

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  ]
}


# If your base module is disabled
module "eks" {
  source               = "../../"
  cluster_name         = local.eks_cluster_name
  enabled              = true
  external_cluster     = true
  subnet_filter_name   = "tag:kubernetes.io/cluster/${local.eks_cluster_name}"
  subnet_filter_values = ["owned", "shared"]
  region               = local.region
  node_role_arn        = module.node-group-role.arn
  subnet_ids           = data.aws_eks_cluster.this.vpc_config[0].subnet_ids

  managed_node_group_defaults = {
    subnet_ids                          = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
    nodes_additional_security_group_ids = [""] # Replace with your actual security group IDs if needed
    tags = {
      "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
      "k8s.io/cluster/${local.eks_cluster_name}"        = "shared"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
          encrypted   = false
        }
      }
    }
  }

  managed_node_group = {
    additional = {
      name                 = "additional"
      capacity_type        = "SPOT"
      min_size             = 1
      max_size             = 2
      desired_size         = 1
      force_update_version = true
      instance_types       = ["t3.medium"]
      ami_type             = "BOTTLEROCKET_x86_64"
    }
  }
}