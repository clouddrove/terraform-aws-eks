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

variable "ondemand_instance_type" {
  type        = list
  default     = []
  description = "Instance type to launch."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`."
}

variable "ondemand_max_size" {
  type        = list
  default     = []
  description = "The maximum size of the autoscale group."
}

variable "ondemand_min_size" {
  type        = list
  default     = []
  description = "The minimum size of the autoscale group."
}

variable "ondemand_desired_capacity" {
  type        = list
  default     = []
  description = "The desired size of the autoscale group."
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

variable "ondemand_enabled" {
  type        = bool
  default     = false
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
  default     = true
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

variable "ondemand_schedule_min_size_scaledown" {
  type        = list
  default     = []
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "ondemand_schedule_max_size_scaledown" {
  type        = list
  default     = []
  description = "The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}


variable "ondemand_schedule_desired_scale_down" {
  type        = list
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "ondemand_schedule_desired_scaleup" {
  type        = list
  default     = []
  description = "The schedule desired size of the autoscale group."
}

variable "ondemand_schedule_max_size_scaleup" {
  type        = list
  default     = []
  description = "The schedule maximum size of the autoscale group."
}

variable "ondemand_schedule_min_size_scaleup" {
  type        = list
  default     = []
  description = "The schedule minimum size of the autoscale group."
}

variable "spot_schedule_desired_scaleup" {
  type        = list
  default     = []
  description = "The schedule desired size of the autoscale group."
}

variable "spot_schedule_max_size_scaleup" {
  type        = list
  default     = []
  description = "The schedule maximum size of the autoscale group."
}

variable "spot_schedule_min_size_scaleup" {
  type        = list
  default     = []
  description = "The schedule minimum size of the autoscale group."
}


variable "spot_schedule_desired_scale_down" {
  type        = list
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}
variable "spot_schedule_min_size_scaledown" {
  type        = list
  default     = []
  description = "The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "spot_schedule_max_size_scaledown" {
  type        = list
  default     = []
  description = "The maximum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "ondemand_scale_up_desired" {
  type        = number
  default     = 1
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_up_desired" {
  type        = list
  default     = []
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
  type        = list
  default     = []
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  type        = list
  default     = []
  description = "Sport instance type to launch."
}

variable "spot_max_size" {
  type        = list
  default     = []
  description = "The maximum size of the spot autoscale group."
}

variable "spot_min_size" {
  type        = list
  default     = []
  description = "The minimum size of the spot autoscale group."
}

variable "spot_desired_capacity" {
  type        = list
  default     = []
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "ondemand_schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource"
}

variable "spot_schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource for spot"
}


variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to `AL2_x86_64`. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`. Terraform will only perform drift detection if a configuration value is provided"
}

variable "ondemand_desired_size" {
  type        = number
  default     = 2
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

variable "public_access_cidrs" {
  type        = list(string)
  default     = []
  description = "The list of cidr blocks to access AWS EKS cluster endpoint. Default [`0.0.0.0/0`]"
}

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate profile is enabled or not"
}

variable "cluster_namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace for selection"
}


variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "The ARN of the KMS Key"
}


variable "cluster_encryption_config_resources" {
  type        = list
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = false
  description = "Set to `true` to enable Cluster Encryption Configuration"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
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

variable "oidc_provider_enabled" {
  type        = bool
  default     = false
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
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

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}


variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}



variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}


variable "kubernetes_config_map_ignore_role_changes" {
  type        = bool
  default     = true
  description = "Set to `true` to ignore IAM role changes in the Kubernetes Auth ConfigMap"
}


variable "node_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes."
}


#node_group

variable "node_groups" {
  description = "Node group configurations"
  type = map(object({
    node_group_name           = string
    subnet_ids                = list(string)
    ami_type                  = string
    node_group_volume_size    = number
    node_group_instance_types = list(string)
    kubernetes_labels         = map(string)
    kubernetes_version        = string
    node_group_desired_size   = number
    node_group_max_size       = number
    node_group_min_size       = number 
  }))
  default = {
    tools = {
      node_group_name           = "tools"
      subnet_ids                = ["subnet-0314766e56d1eff14","subnet-051b8c18ce7c0c8ea","subnet-0a3ba212912cb4263"]
      ami_type                  = "AL2_x86_64"
      node_group_volume_size    = 20
      node_group_instance_types = ["t3.small"]
      kubernetes_labels         = {}
      kubernetes_version        = "1.18" 
      node_group_desired_size   = 1
      node_group_max_size       = 2
      node_group_min_size       = 1    
    }
  }
}

variable "node_group_enabled" {
  type        = bool
  default     = false
  description = "Enabling or disabling the node group."
}

variable "before_cluster_joining_userdata" {
  type        = string
  default     = ""
  description = "Additional commands to execute on each worker node before joining the EKS cluster (before executing the `bootstrap.sh` script). For more info, see https://kubedex.com/90-days-of-aws-eks-in-production"
}
