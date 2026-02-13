# Security Baselines for `terraform-aws-eks`

This repository now includes two opinionated security examples:

1. `examples/secure-cluster-baseline`
   - Public + private endpoint enabled
   - Public endpoint restricted via CIDR allowlist
   - Control plane logs enabled (`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`)
   - CloudWatch log retention set to 90 days
   - KMS key rotation enabled

2. `examples/private-endpoint-baseline`
   - Public endpoint disabled
   - Private endpoint enabled
   - Same control-plane logging and KMS defaults as above

## Guidance
- Prefer `private-endpoint-baseline` for regulated/internal environments.
- Use `secure-cluster-baseline` when limited public API access is required.
- Pair with `terraform-aws-eks-addons` compliance baseline for runtime controls and observability.
