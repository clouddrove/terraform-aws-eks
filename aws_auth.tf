

# The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster
# to allow worker nodes to join the cluster via AWS IAM role authentication.

# NOTE: To automatically apply the Kubernetes configuration to the cluster (which allows the worker nodes to join the cluster),
# the requirements outlined here must be met:
# https://learn.hashicorp.com/terraform/aws/eks-intro#preparation
# https://learn.hashicorp.com/terraform/aws/eks-intro#configuring-kubectl-for-eks
# https://learn.hashicorp.com/terraform/aws/eks-intro#required-kubernetes-configuration-to-join-worker-nodes

# Additional links
# https://learn.hashicorp.com/terraform/aws/eks-intro
# https://itnext.io/how-does-client-authentication-work-on-amazon-eks-c4f2b90d943b
# https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
# https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
# https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html
# https://docs.aws.amazon.com/en_pv/eks/latest/userguide/create-kubeconfig.html
# https://itnext.io/kubernetes-authorization-via-open-policy-agent-a9455d9d5ceb
# http://marcinkaszynski.com/2018/07/12/eks-auth.html
# https://cloud.google.com/kubernetes-engine/docs/concepts/configmap
# http://yaml-multiline.info
# https://github.com/terraform-providers/terraform-provider-kubernetes/issues/216
# https://www.terraform.io/docs/cloud/run/install-software.html
# https://stackoverflow.com/questions/26123740/is-it-possible-to-install-aws-cli-package-without-root-permission
# https://stackoverflow.com/questions/58232731/kubectl-missing-form-terraform-cloud
# https://docs.aws.amazon.com/cli/latest/userguide/install-bundle.html
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html

resource "null_resource" "wait_for_cluster" {
  count      = var.enabled && var.external_cluster == false && var.apply_config_map_aws_auth ? 1 : 0
  depends_on = [aws_eks_cluster.default[0]]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_command
    interpreter = var.local_exec_interpreter
    environment = {
      ENDPOINT = aws_eks_cluster.default[0].endpoint
    }
  }
}

data "aws_eks_cluster" "eks" {
  count = var.enabled && var.external_cluster == false && var.apply_config_map_aws_auth ? 1 : 0
  name  = aws_eks_cluster.default[0].id
}

# Get an authentication token to communicate with the EKS cluster.
# By default (before other roles are added to the Auth ConfigMap), you can authenticate to EKS cluster only by assuming the role that created the cluster.
# `aws_eks_cluster_auth` uses IAM credentials from the AWS provider to generate a temporary token.
# If the AWS provider assumes an IAM role, `aws_eks_cluster_auth` will use the same IAM role to get the auth token.
# https://www.terraform.io/docs/providers/aws/d/eks_cluster_auth.html
data "aws_eks_cluster_auth" "eks" {
  count = var.enabled && var.external_cluster == false && var.apply_config_map_aws_auth ? 1 : 0
  name  = aws_eks_cluster.default[0].id
}

provider "kubernetes" {
  token                  = var.apply_config_map_aws_auth && var.external_cluster == false ? data.aws_eks_cluster_auth.eks[0].token : ""
  host                   = var.apply_config_map_aws_auth && var.external_cluster == false ? data.aws_eks_cluster.eks[0].endpoint : ""
  cluster_ca_certificate = var.apply_config_map_aws_auth && var.external_cluster == false ? base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data) : ""
}

resource "kubernetes_config_map" "aws_auth_ignore_changes" {
  count      = var.enabled && var.external_cluster == false && var.apply_config_map_aws_auth ? 1 : 0
  depends_on = [null_resource.wait_for_cluster[0]]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = yamlencode(distinct(concat(local.map_worker_roles, var.map_additional_iam_roles)))
    mapUsers    = yamlencode(var.map_additional_iam_users)
    mapAccounts = yamlencode(var.map_additional_aws_accounts)
  }

  lifecycle {
    ignore_changes = [data["mapRoles"]]
  }
}