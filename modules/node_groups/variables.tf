variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "node_groups" {
  type        = list
  default     = []
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "max_size" {
  type        = list
  default     = []
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "min_size" {
  type        = list
  default     = []
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "desired_size" {
  type        = list
  default     = []
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "aws_iam_role_arn" {
  type        = string
  default     = ""
  description = "ARN of EKS iam user"

}

variable "subnet_ids" {
  type  = list
  default = []
  description = "subnet_ids"
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

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the EKS cluster."
}

