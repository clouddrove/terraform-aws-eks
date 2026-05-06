# EKS RBAC Examples

This directory contains multiple examples demonstrating different ways to provision and manage EKS clusters using Terraform (e.g., managed node groups, self-managed nodes, Fargate, etc.).

Some of these examples also demonstrate how to configure Kubernetes RBAC using Terraform and YAML manifests.

---

## 🔑 Key Concepts

* **ClusterRole** → defines permissions (read, write, etc.)
* **ClusterRoleBinding** → assigns those permissions to a group
* **IAM mapping** → connects AWS IAM roles/users to those groups

---

## 📁 How This Example Works

### 1. YAML Files (RBAC Rules)

RBAC configurations are stored in the [`aws_managed/yamls/`](./aws_managed/yamls) directory.

These files:

* Define roles (permissions)
* Assign roles to groups

Terraform applies them using:

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

---

### 2. Grant Read-Only Access

```hcl
apply_config_map_aws_auth = true

map_additional_iam_roles = [
  {
    rolearn  = "arn:aws:iam::123456789:role/YourIAMRoleName"
    username = "readonly"
    groups   = ["view"]
  }
]
```

✅ Result:

* IAM role → `view` group
* `view` group → read-only access

---

### 3. Grant Read-Write Access

```hcl
apply_config_map_aws_auth = true

map_additional_iam_roles = [
  {
    rolearn  = "arn:aws:iam::123456789:role/YourIAMRoleName"
    username = "read-write"
    groups   = ["read-write"]
  }
]
```

➡️ This group is linked to a custom role with write permissions.

---

## 📄 Available YAML Files

| File | Purpose |
|------|---------|
| [`ClusterRoleBinding-View.yaml`](./aws_managed/yamls/ClusterRoleBinding-View.yaml) | Read-only access across the cluster |
| [`RoleBinding-View-Namespace.yaml`](./aws_managed/yamls/RoleBinding-View-Namespace.yaml) | Read-only access in a namespace |
| [`ClusterRole-ReadWrite.yaml`](./aws_managed/yamls/ClusterRole-ReadWrite.yaml) | Custom read-write role |
| [`ClusterRoleBinding-ReadWrite.yaml`](./aws_managed/yamls/ClusterRoleBinding-ReadWrite.yaml) | Read-write access across the cluster |
| [`RoleBinding-ReadWrite-Namespace.yaml`](./aws_managed/yamls/RoleBinding-ReadWrite-Namespace.yaml) | Read-write access in a namespace |

---

## ▶️ Usage

```bash
cd aws_managed
terraform init
terraform plan
terraform apply
```

---

## 🔄 What Happens After Apply

Terraform will:

1. Create the EKS cluster
2. Update the `aws-auth` ConfigMap
3. Map IAM roles to Kubernetes groups
4. Apply RBAC YAML files
