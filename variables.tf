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

variable "workers_security_group_id" {
  type        = string
  default     = ""
  description = "The name of the existing security group that will be used in autoscaling group for EKS workers. If empty, a new security group will be created."
}

variable "use_existing_security_group" {
  type        = bool
  description = "If set to `true`, will use variable `workers_security_group_id` to run EKS workers using an existing security group that was created outside of this module, workaround for errors like `count cannot be computed`."
  default     = false
}

variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional list of security groups that will be attached to the autoscaling group."
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

variable "image_id" {
  type        = string
  default     = ""
  description = "EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images."
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

variable "key_name" {
  type        = string
  default     = ""
  description = "SSH key name that should be used for the instance."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "eks_subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch resources in EKS."
}

variable "worker_subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch resources in workers."
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = false
  description = "Whether to generate local files from `kubeconfig` and `config_map_aws_auth` and perform `kubectl apply` to apply the ConfigMap to allow the worker nodes to join the EKS cluster."
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

variable "ebs_encryption" {
  type        = bool
  default     = false
  description = "Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot_id."
}

variable "kms_key" {
  type        = string
  default     = ""
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
}

variable "scheduler_down" {
  type        = string
  default     = "0 19 * * MON-FRI" # 21:00  CET
  description = "What is the recurrency for scaling up operations ?"

}

variable "scheduler_up" {
  type        = string
  default     = "0 6 * * MON-FRI" # 07:00 CET
  description = "What is the recurrency for scaling down operations ?"
}

variable "min_size_scaledown" {
  type        = number
  default     = 1
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "max_size_scaledown" {
  type        = number
  default     = 1
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "spot_min_size_scaledown" {
  type        = number
  default     = 1
  description = "The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "spot_max_size_scaledown" {
  type        = number
  default     = 1
  description = "The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "scale_down_desired" {
  type        = number
  default     = 1
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_down_desired" {
  type        = number
  default     = 1
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "scale_up_desired" {
  type        = number
  default     = 1
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_up_desired" {
  type        = number
  default     = 1
  description = " The number of Amazon EC2 instances that should be running in the group."
}

###Spot
variable "spot_enabled" {
  type        = bool
  default     = false
  description = "Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances."
}

variable "instance_interruption_behavior" {
  type        = string
  default     = "terminate"
  description = "The behavior when a Spot Instance is interrupted. Can be hibernate, stop, or terminate. (Default: terminate)."
}

variable "max_price" {
  type        = string
  default     = ""
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Sport instance type to launch."
}


variable "spot_max_size" {
  type        = number
  default     = 5
  description = "The maximum size of the spot autoscale group."
}

variable "spot_min_size" {
  type        = number
  default     = 2
  description = "The minimum size of the spot autoscale group."
}

variable "schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource"
}

variable "spot_schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource for spot"
}

variable "node_group_enabled" {
  type        = bool
  default     = false
  description = "Enabling or disabling the node group"
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided"  
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "ami_release_version" {
  type        = string
  default     = ""
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version"
}

variable "kubernetes_labels" {
  type        = map
  default     = {}
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
}

variable "node_group_instance_types" {
  type        = list
  default     = []
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = []
  description = "The list of cidr blocks to access AWS EKS cluster endpoint. Default [`0.0.0.0/0`]"
}

variable "key_usage" {
  type        = string
  default     = ""
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY. Defaults to ENCRYPT_DECRYPT."
}

variable "customer_master_key_spec" {
  type        = string
  default     = ""
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