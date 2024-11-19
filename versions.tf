# Terraform version
terraform {
  required_version = ">= 1.5.4"
  kubernetes = ">= 2.33.0"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0"
    }
  }
}