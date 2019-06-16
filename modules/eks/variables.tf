variable "application" {
  type        = "string"
  description = "Application, which could be your Application name, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = "string"
  default     = ""
  description = "Environment, e.g. 'testing', 'UAT'"
}

variable "name" {
  type        = "string"
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "enabled" {
  type        = "string"
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID for the EKS cluster"
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch the cluster in"
  type        = "list"
}

variable "allowed_security_groups" {
  type        = "list"
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster"
}

variable "allowed_cidr_blocks" {
  type        = "list"
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster"
}

variable "workers_security_group_ids" {
  type        = "list"
  description = "Security Group IDs of the worker nodes"
}

variable "workers_security_group_count" {
  description = "Count of the worker Security Groups. Needed to prevent Terraform error `count can't be computed`"
}

variable "kubernetes_version" {
  type        = "string"
  default     = ""
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
}

variable "endpoint_private_access" {
  type        = "string"
  default     = "false"
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}

variable "endpoint_public_access" {
  type        = "string"
  default     = "true"
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}

variable "enabled_cluster_log_types" {
  type        = "list"
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}
