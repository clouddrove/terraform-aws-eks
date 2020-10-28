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

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the EKS cluster."
}


variable "aws_iam_instance_profile_name" {
  type        = string
  default     = ""
  description = "The name of the existing instance profile that will be used in autoscaling group for EKS workers. If empty will create a new instance profile."
}
variable "volume_size" {
  type        = number
  default     = 20
  description = "The size of ebs volume."
}

variable "volume_type" {
  type        = string
  default     = "standard"
  description = "The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`)."
}

variable "node_group_enabled" {
  type        = bool
  default     = false
  description = "Enabling or disabling the node group."
}

variable "node_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes."
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided"
}

variable "node_group_desired_size" {
  type        = number
  default     = 2
  description = "Desired number of worker node groups"
}

variable "node_group_max_size" {
  type        = number
  default     = 3
  description = "The maximum size of the autoscale node group."
}

variable "node_group_min_size" {
  type        = number
  default     = 1
  description = "The minimum size of the autoscale node group."
}

variable "ami_release_version" {
  type        = string
  default     = ""
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch resources in EKS."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "SSH key name that should be used for the instance."
}

variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided"
}

variable "kubernetes_labels" {
  type        = map
  default     = {}
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
}

variable "node_group_instance_types" {
  type        = list(string)
  default     = []
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
}


variable "cluster_namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace for selection"
}

variable "enable_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Whether to enable node group to scale the Auto Scaling Group"
}

variable "node_group_volume_size" {
  type        = number
  default     = 20
  description = "Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided"
}

variable "node_group_name" {
  type        = string
  default     = ""
  description = "Name of node group"
}

variable "module_depends_on" {
  type        = any
  default     = null
  description = "Can be any value desired. Module will wait for this value to be computed before creating node group."
}

variable "before_cluster_joining_userdata" {
  type        = string
  default     = ""
  description = "Additional commands to execute on each worker node before joining the EKS cluster (before executing the `bootstrap.sh` script). For more info, see https://kubedex.com/90-days-of-aws-eks-in-production"
}

variable "node_role_arn" {
  type        = string
  default     = ""
  description = "ARN of role profile."
}