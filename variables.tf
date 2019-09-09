variable "application" {
  type        = string
  default     = "uplift"
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = "qa"
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "name" {
  type        = string
  default     = "uplift"
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "allowed_security_groups_cluster" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster."
}

variable "allowed_security_groups_workers" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the worker nodes."
}

variable "allowed_cidr_blocks_cluster" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster."
}

variable "allowed_cidr_blocks_workers" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the worker nodes."
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "172.30.0.0/16"
  description = "VPC CIDR block. See https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html for more details."
}

variable "image_id" {
  type        = string
  default     = "ami-0abcb9f9190e867ab"
  description = "EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images."
}

variable "eks_worker_ami_name_filter" {
  type        = string
  default     = "amazon-eks-node-v*"
  description = "AMI name filter to lookup the most recent EKS AMI if `image_id` is not provided."
}

variable "instance_type" {
  type        = string
  default     = "t2.nano"
  description = "Instance type to launch."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`."
}

variable "max_size" {
  default     = 1
  description = "The maximum size of the AutoScaling Group."
}

variable "min_size" {
  default     = 1
  description = "The minimum size of the AutoScaling Group."
}

variable "wait_for_capacity_timeout" {
  type        = string
  default     = "15m"
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = true
  description = "Associate a public IP address with the worker nodes in the VPC."
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling."
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  default     = 80
  description = "Worker nodes AutoScaling Group CPU utilization high threshold percent."
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  default     = 20
  description = "Worker nodes AutoScaling Group CPU utilization low threshold percent."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  description = "Availability Zones for the cluster."
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = true
  description = "Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster."
}

variable "key_name" {
  type    = string
  default = ""
  description = "SSH key name that should be used for the instance."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch resources in."
}