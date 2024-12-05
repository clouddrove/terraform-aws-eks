#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-eks"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "eks_tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags for EKS Cluster only."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

#---------------------------------------------------------EKS-----------------------------------------------------------
variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]."
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 30
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "oidc_provider_enabled" {
  type        = bool
  default     = true
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}
variable "eks_additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "EKS additional security group id"
}
variable "nodes_additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "EKS additional node group ids"
}
variable "addons" {
  type = any
  default = [
    {
      addon_name        = "coredns"
      addon_version     = "v1.10.1-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    },
    {
      addon_name        = "kube-proxy"
      addon_version     = "v1.27.3-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    },
    {
      addon_name        = "vpc-cni"
      addon_version     = "v1.13.4-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    },
  ]
  description = "Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources."
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = null
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "cluster_service_ipv6_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from if `ipv6` was specified when the cluster was created. Kubernetes assigns service addresses from the unique local address range (fc00::/7) because you can't specify a custom IPv6 CIDR block when you create the cluster"
  type        = string
  default     = null
}

variable "outpost_config" {
  description = "Configuration for the AWS Outpost to provision the cluster on"
  type        = any
  default     = {}
}

#-----------------------------------------------------------KMS---------------------------------------------------------
variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` to enable Cluster Encryption Configuration"
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  default     = null
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
}

variable "openid_connect_audiences" {
  type        = list(string)
  default     = []
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
}


#---------------------------------------------------------IAM-----------------------------------------------------------
variable "permissions_boundary" {
  type        = string
  default     = null
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

#---------------------------------------------------------Security_Group------------------------------------------------
variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster."
}

#------------------------------------------------------------Networking-------------------------------------------------
variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch the cluster in."
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false."
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of security group IDs to associate"
}
#-----------------------------------------------TimeOuts----------------------------------------------------------------

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# Self Managed Node Group
################################################################################

variable "self_node_groups" {
  type        = any
  default     = {}
  description = "Map of self-managed node group definitions to create"
}

variable "self_node_group_defaults" {
  type        = any
  default     = {}
  description = "Map of self-managed node group default configurations"
}

# AWS auth
variable "apply_config_map_aws_auth" {
  type        = bool
  default     = true
  description = "Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster."
}

variable "wait_for_cluster_command" {
  type        = string
  default     = "curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"
  description = "`local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT`"
}

variable "local_exec_interpreter" {
  type        = list(string)
  default     = ["/bin/sh", "-c"]
  description = "shell to use for local_exec"
}

variable "map_additional_iam_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default     = []
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"
}

variable "map_additional_iam_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default     = []
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"
}

variable "map_additional_aws_accounts" {
  type        = list(string)
  default     = []
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
}

#Managed
variable "managed_node_group_defaults" {
  type        = any
  default     = {}
  description = "Map of eks-managed node group definitions to create"
}

variable "managed_node_group" {
  type        = any
  default     = {}
  description = "Map of eks-managed node group definitions to create"
}

#-----------------------------------------------ASG-Schedule----------------------------------------------------------------

variable "schedules" {
  description = "Map of autoscaling group schedule to create"
  type        = map(any)
  default     = {}
}

##fargate profile

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate profile is enabled or not"
}

variable "fargate_profiles" {
  type        = map(any)
  default     = {}
  description = "The number of Fargate Profiles that would be created."
}