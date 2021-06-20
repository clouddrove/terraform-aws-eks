terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.1.15"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}
