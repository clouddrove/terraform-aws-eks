provider "aws" {
  region = "ca-central-1"
}

module "eks" {
  source      = "../../"
  name        = "eks"
  environment = "test"
}
