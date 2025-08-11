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
  source               = "../../"
  cluster_name         = local.eks_cluster_name
  enabled              = true
  external_cluster     = true
  subnet_filter_name   = "tag:kubernetes.io/cluster/${local.eks_cluster_name}"
  subnet_filter_values = ["owned", "shared"]
  region               = local.region
  node_role_arn        = data.aws_eks_cluster.this.role_arn
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