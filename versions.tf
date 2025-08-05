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
  }
}

