# terraform-aws-eks basic example

This is a basic example of the `terraform-aws-eks` module.

## Usage

```hcl
module "eks" {
  source      = "clouddrove/eks/aws"
  name        = "eks"
  environment = "test"
}
```
