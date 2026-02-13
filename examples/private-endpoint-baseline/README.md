# Private Endpoint Baseline (AWS Managed Nodes)

This example provisions an EKS cluster where API endpoint access is private-only:
- public endpoint disabled
- private endpoint enabled
- control plane logs enabled with longer retention
- encrypted node volumes using KMS

## Usage
```bash
cd examples/private-endpoint-baseline
terraform init
terraform plan
terraform apply
```
