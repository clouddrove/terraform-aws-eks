# Terraform version
terraform {
  required_version = ">= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0" # Update to the minimum required version
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.3" # Update to the minimum required version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.33.0" # Update to the minimum required version
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6" # Specify the appropriate version
    }
  }
}