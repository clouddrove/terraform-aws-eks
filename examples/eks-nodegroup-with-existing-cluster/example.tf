##--------------------------------------------------------------------
## LOCALS
##--------------------------------------------------------------------
locals {
  eks_cluster_name = "clouddrove-eks"
  region           = "us-east-2"
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
  name   = local.eks_cluster_name
  region = local.region
}

# Fetch authentication token for the EKS cluster
data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

##--------------------------------------------------------------------
## MODULE CALL
##--------------------------------------------------------------------

# If your base module is disabled
module "eks" {
  source           = "../../"
  cluster_name     = local.eks_cluster_name
  enabled          = true
  external_cluster = true
  region           = local.region
  node_role_arn    = "YOUR_NODE_ROLE_ARN" # Replace with your actual node role ARN
  subnet_ids       = data.aws_eks_cluster.this.vpc_config[0].subnet_ids

  managed_node_group_defaults = {
    subnet_ids                          = data.aws_eks_cluster.this.vpc_config[0].subnet_ids
    nodes_additional_security_group_ids = ["sg-05032c5f9d2c313be", "sg-098dde088819d13c1"]
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