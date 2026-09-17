# Terraform version
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # >= 6.25.0 is required for the aws_eks_capability resource (EKS Capabilities: ACK, ArgoCD, KRO)
      version = ">= 6.25.0, < 7.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }

  provider_meta "aws" {
    user_agent = ["github.com/clouddrove/terraform-aws-eks"]
  }
}

