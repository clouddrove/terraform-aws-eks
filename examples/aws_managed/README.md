# AWS Managed EKS Example

This example creates an EKS cluster with AWS managed node groups. It also shows how to create and assign read-only access to EKS by using Kubernetes RBAC YAML files and `map_additional_iam_roles`.

## Read-only EKS access with YAML RBAC

The Kubernetes RBAC manifests are stored in the [`yamls`](./yamls) directory and are applied by the `kubectl_manifest.cluster_roles` resource in [`example.tf`](./example.tf).

```hcl
locals {
  kubectl_cluster_role_yaml_files = [
    "${path.module}/yamls/ClusterRole-ReadWrite.yaml",
    "${path.module}/yamls/ClusterRoleBinding-View.yaml",
    "${path.module}/yamls/RoleBinding-View-Namespace.yaml",
    "${path.module}/yamls/ClusterRoleBinding-ReadWrite.yaml",
    "${path.module}/yamls/RoleBinding-ReadWrite-Namespace.yaml",
  ]
}

resource "kubectl_manifest" "cluster_roles" {
  for_each  = toset(local.kubectl_cluster_role_yaml_files)
  yaml_body = file(each.value)

  depends_on = [
    module.eks,
    data.aws_eks_cluster.this,
    data.aws_eks_cluster_auth.this,
  ]
}
```

To give an IAM role read-only access to the EKS cluster, map the IAM role to the Kubernetes `view` group in `map_additional_iam_roles`. The [`yamls/ClusterRoleBinding-View.yaml`](./yamls/ClusterRoleBinding-View.yaml) manifest binds the `view` group to Kubernetes' built-in `view` ClusterRole.

```hcl
apply_config_map_aws_auth = true

map_additional_iam_roles = [
  {
    rolearn  = "arn:aws:iam::123456789:role/AWSReservedSSO_ReadOnlyAccess_xxxxxxxx"
    username = "readonly"
    groups   = ["view"]
  }
]
```

Use the same `groups = ["view"]` mapping with `map_additional_iam_users` when granting read-only access to an IAM user instead of an IAM role.

## Available YAML files

| File | Purpose |
|------|---------|
| [`ClusterRoleBinding-View.yaml`](./yamls/ClusterRoleBinding-View.yaml) | Binds the `view` group to the built-in read-only `view` ClusterRole for cluster-wide read-only access. |
| [`RoleBinding-View-Namespace.yaml`](./yamls/RoleBinding-View-Namespace.yaml) | Binds the `namespace-view` group to the built-in `view` ClusterRole in the `default` namespace. |
| [`ClusterRole-ReadWrite.yaml`](./yamls/ClusterRole-ReadWrite.yaml) | Creates a custom `read-write` ClusterRole. |
| [`ClusterRoleBinding-ReadWrite.yaml`](./yamls/ClusterRoleBinding-ReadWrite.yaml) | Binds the `read-write` group to the custom `read-write` ClusterRole for cluster-wide read-write access. |
| [`RoleBinding-ReadWrite-Namespace.yaml`](./yamls/RoleBinding-ReadWrite-Namespace.yaml) | Binds the `namespace-read-write` group to the custom `read-write` ClusterRole in the `default` namespace. |

## Usage

Run Terraform from this example directory:

```bash
terraform init
terraform plan
terraform apply
```

After apply, Terraform updates the `aws-auth` ConfigMap with the roles from `map_additional_iam_roles` and applies the YAML RBAC manifests to the EKS cluster.
