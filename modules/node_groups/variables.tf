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

