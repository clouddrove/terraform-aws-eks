variable "application" {
  type        = "string"
  default     = "uplift"
  description = "Application, which could be your Application name, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = "string"
  default     = "qa"
  description = "Environment, e.g. 'testing', 'UAT'"
}

variable "name" {
  type        = "string"
  default     = "uplift"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "vpc_cidr_block" {
  type        = "string"
  default     = "172.30.0.0/16"
  description = "VPC CIDR block. See https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html for more details"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.nano"
  description = "Instance type to launch"
}

variable "availability_zones" {
  type        = "list"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  description = "Availability Zones for the cluster"
}

variable "key_name" {
  type    = "string"
  default = ""
}
