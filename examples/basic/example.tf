provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source      = "../../"
  name        = "eks"
  environment = "test"
}
