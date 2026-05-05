terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 5.80.0"
    }
  }
}
