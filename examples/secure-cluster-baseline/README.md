# Secure Cluster Baseline (AWS Managed Nodes)

This example provisions an EKS cluster with security-forward defaults:
- private endpoint enabled
- public endpoint restricted to VPC CIDR
- control plane logs enabled with longer retention
- encrypted node volumes using KMS
- Bottlerocket node AMI

## Usage
```bash
cd examples/secure-cluster-baseline
terraform init
terraform plan
terraform apply
```
