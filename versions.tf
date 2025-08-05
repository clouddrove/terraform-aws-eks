# Terraform version
terraform {
  required_version = ">= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2" # or latest stable version you're comfortable with
    }
  }
}

