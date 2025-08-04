locals {
  name   = "clouddrove-eks-test-arzian-01-test-cluster"
  region = "us-east-1"
}

# If your base module is disabled
module "eks" {
  source = "../../"
  cluster_name = local.name
  enabled          = true
  external_cluster = true
  region           = local.region
  # subnet_ids       = data.aws_eks_cluster.eks_cluster.vpc_config[0].subnet_ids
  managed_node_group = {

  application = {
    name                 = "${module.eks.cluster_name}-application"
    capacity_type        = "SPOT"
    min_size             = 1
    max_size             = 2
    desired_size         = 1
    force_update_version = true
    instance_types       = ["t3.medium"]
    ami_type             = "BOTTLEROCKET_x86_64"
  }
    managed_node_group-2 = {
    application = {
      name                 = "${local.name}-application"
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
}

provider "aws" {
  region = local.region
}

# Fetch existing EKS cluster
data "aws_eks_cluster" "this" {
  name   = local.name
  region = local.region
}

# Fetch authentication token for the EKS cluster
data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

# Kubernetes provider using the fetched cluster's details
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
