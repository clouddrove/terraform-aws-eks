#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to launch the cluster in."
}

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

variable "workers_security_group_ids" {
  type        = list(string)
  description = "Security Group IDs of the worker nodes."
}

variable "workers_security_group_count" {
  description = "Count of the worker Security Groups. Needed to prevent Terraform error `count can't be computed`."
}

variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false."
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true."
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]."
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = []
  description = "The list of cidr blocks to access AWS EKS cluster endpoint. Default [`0.0.0.0/0`]"
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY. Defaults to ENCRYPT_DECRYPT."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled. Defaults to true." 
}

variable "enable_key_rotation" {
  type        = bool
  default     = false
  description = "Specifies whether key rotation is enabled. Defaults to false."
}

variable "resources" {
  type        = list(string)
  default     = []
  description = "List of strings with resources to be encrypted. Valid values: secrets"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "The AWS account id of the user."
}

variable "kms_encryption_enabled" {
  type        = bool
  default     = false
  description = "Whether kms encryption is enabled or not"
}