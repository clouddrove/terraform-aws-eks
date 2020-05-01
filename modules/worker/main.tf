## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
  node_group_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/enabled" = "${var.node_group_enabled}"
    }
  )
  enabled                       = var.enabled && var.autoscaling_policies_enabled ? true : false
  use_existing_instance_profile = var.aws_iam_instance_profile_name != "" ? true : false
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  tags        = local.tags
  attributes  = compact(concat(var.attributes, ["workers"]))
  label_order = var.label_order
}

module "node_group_labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  tags        = local.node_group_tags
  attributes  = compact(concat(var.attributes, ["nodes"]))
  label_order = var.label_order
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled && local.use_existing_instance_profile == false ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Autoscaler policy for node group
data "aws_iam_policy_document" "amazon_eks_node_group_autoscaler_policy" {
  count = var.enabled && var.node_group_enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

# AWS EKS Fargate policy
data "aws_iam_policy_document" "aws_eks_fargate_policy" {
  count = var.enabled && var.fargate_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = var.enabled && local.use_existing_instance_profile == false ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
}

resource "aws_iam_role" "fargate_role" {
  count              = var.enabled && var.fargate_enabled ? 1 : 0
  name               = format("%s-fargate-role", module.labels.id)
  assume_role_policy = join("", data.aws_iam_policy_document.aws_eks_fargate_policy.*.json)
}

#Module      : IAM ROLE POLICY ATTACHMENT NODE
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled && local.use_existing_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_policy" "amazon_eks_node_group_autoscaler_policy" {
  count  = var.enabled && var.node_group_enabled ? 1 : 0
  name   = format("%s-node-group-policy", module.labels.id)
  policy = join("", data.aws_iam_policy_document.amazon_eks_node_group_autoscaler_policy.*.json)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_node_group_autoscaler_policy" {
  count      = var.enabled && var.node_group_enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_node_group_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_fargate_pod_execution_role_policy" {
  count      = var.enabled && var.fargate_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = join("", aws_iam_role.fargate_role.*.name)
}

resource "aws_iam_policy" "ecr" {
  count  = var.enabled ? 1 : 0
  name   = format("%s-ecr-policy", module.labels.id)
  policy = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:*",
      "cloudtrail:LookupEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = join("", aws_iam_policy.ecr.*.arn)
}

#Module      : IAM ROLE POLICY ATTACHMENT CNI
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled && local.use_existing_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.default.*.name)
}

#Module      : IAM ROLE POLICY ATTACHMENT EC2 CONTAINER REGISTRY READ ONLY
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled && local.use_existing_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.default.*.name)
}

#Module      : IAM INSTANCE PROFILE
#Description : Provides an IAM instance profile.
resource "aws_iam_instance_profile" "default" {
  count = var.enabled && local.use_existing_instance_profile || var.autoscaling_policies_enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.default.*.name)
}

#Module      : SECURITY GROUP
#Description : Provides a security group resource.
resource "aws_security_group" "default" {
  count       = var.enabled && var.use_existing_security_group == false ? 1 : 0
  name        = module.labels.id
  description = "Security Group for EKS worker nodes"
  vpc_id      = var.vpc_id
  tags        = module.labels.tags
}

#Module      : SECURITY GROUP RULE EGRESS
#Description : Provides a security group rule resource. Represents a single egress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "egress" {
  count             = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

#Module      : SECURITY GROUP RULE INGRESS SELF
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_self" {
  count                    = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE INGRESS CLUSTER
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_cluster" {
  count                    = var.enabled && var.cluster_security_group_ingress_enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = var.cluster_security_group_id
  type                     = "ingress"
}

#Module      : SECURITY GROUP
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled && var.use_existing_security_group == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

#Module      : SECURITY GROUP RULE CIDR BLOCK
#Description : Provides a security group rule resource. Represents a single ingress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

#Module      : EKS Fargate
#Descirption : Enabling fargate for AWS EKS
resource "aws_eks_fargate_profile" "default" {
  count                  = var.enabled && var.fargate_enabled ? 1 : 0
  cluster_name           = var.cluster_name
  fargate_profile_name   = format("%s-fargate-eks", module.labels.id)
  pod_execution_role_arn = join("", aws_iam_role.fargate_role.*.arn)
  subnet_ids             = var.subnet_ids
  tags                   = module.labels.tags

  selector {
    namespace = var.cluster_namespace
    labels    = var.kubernetes_labels
  }
}

#Module:     : NODE GROUP
#Description : Creating a node group for eks cluster
resource "aws_eks_node_group" "default" {
  count           = var.enabled && var.node_group_enabled ? var.number_of_node_groups : 0
  cluster_name    = var.cluster_name
  node_group_name = format("%s-node-group-${count.index + 1}", module.node_group_labels.id)
  node_role_arn   = join("", aws_iam_role.default.*.arn)
  subnet_ids      = var.subnet_ids
  ami_type        = var.ami_type
  disk_size       = var.volume_size
  instance_types  = var.node_group_instance_types
  labels          = var.kubernetes_labels
  release_version = var.ami_release_version
  version         = var.kubernetes_version

  tags = module.node_group_labels.tags

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = var.node_security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_node_group_autoscaler_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
  ]

  lifecycle {
    create_before_destroy = true
  }
}

module "autoscale_group" {
  source = "../autoscaling"

  enabled     = local.enabled
  name        = var.name
  application = var.application
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  label_order = var.label_order

  image_id                  = var.image_id
  iam_instance_profile_name = local.use_existing_instance_profile == false ? join("", aws_iam_instance_profile.default.*.name) : var.aws_iam_instance_profile_name
  security_group_ids = compact(
    concat(
      [
        var.use_existing_security_group == false ? join("", aws_security_group.default.*.id) : var.workers_security_group_id
      ],
      var.additional_security_group_ids
    )
  )
  user_data_base64 = base64encode(join("", data.template_file.userdata.*.rendered))
  tags             = module.labels.tags

  instance_type                           = var.instance_type
  subnet_ids                              = var.subnet_ids
  min_size                                = var.min_size
  max_size                                = var.max_size
  spot_max_size                           = var.spot_max_size
  spot_min_size                           = var.spot_min_size
  spot_enabled                            = var.spot_enabled
  scheduler_down                          = var.scheduler_down
  scheduler_up                            = var.scheduler_up
  min_size_scaledown                      = var.min_size_scaledown
  max_size_scaledown                      = var.max_size_scaledown
  spot_min_size_scaledown                 = var.spot_min_size_scaledown
  spot_max_size_scaledown                 = var.spot_max_size_scaledown
  schedule_enabled                        = var.schedule_enabled
  spot_schedule_enabled                   = var.spot_schedule_enabled
  spot_scale_down_desired                 = var.spot_scale_down_desired
  spot_scale_up_desired                   = var.spot_scale_up_desired
  scale_up_desired                        = var.scale_up_desired
  scale_down_desired                      = var.scale_down_desired
  max_price                               = var.max_price
  volume_size                             = var.volume_size
  ebs_encryption                          = var.ebs_encryption
  kms_key_arn                             = var.kms_key_arn
  volume_type                             = var.volume_type
  spot_instance_type                      = var.spot_instance_type
  associate_public_ip_address             = var.associate_public_ip_address
  instance_initiated_shutdown_behavior    = var.instance_initiated_shutdown_behavior
  key_name                                = var.key_name
  enable_monitoring                       = var.enable_monitoring
  load_balancers                          = var.load_balancers
  health_check_grace_period               = var.health_check_grace_period
  health_check_type                       = var.health_check_type
  min_elb_capacity                        = var.min_elb_capacity
  target_group_arns                       = var.target_group_arns
  default_cooldown                        = var.default_cooldown
  force_delete                            = var.force_delete
  termination_policies                    = var.termination_policies
  suspended_processes                     = var.suspended_processes
  enabled_metrics                         = var.enabled_metrics
  metrics_granularity                     = var.metrics_granularity
  wait_for_capacity_timeout               = var.wait_for_capacity_timeout
  protect_from_scale_in                   = var.protect_from_scale_in
  service_linked_role_arn                 = var.service_linked_role_arn
  autoscaling_policies_enabled            = var.autoscaling_policies_enabled
  scale_up_cooldown_seconds               = var.scale_up_cooldown_seconds
  scale_up_scaling_adjustment             = var.scale_up_scaling_adjustment
  scale_up_adjustment_type                = var.scale_up_adjustment_type
  scale_up_policy_type                    = var.scale_up_policy_type
  scale_down_cooldown_seconds             = var.scale_down_cooldown_seconds
  scale_down_scaling_adjustment           = var.scale_down_scaling_adjustment
  scale_down_adjustment_type              = var.scale_down_adjustment_type
  scale_down_policy_type                  = var.scale_down_policy_type
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period_seconds     = var.cpu_utilization_high_period_seconds
  cpu_utilization_high_threshold_percent  = var.cpu_utilization_high_threshold_percent
  cpu_utilization_high_statistic          = var.cpu_utilization_high_statistic
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period_seconds      = var.cpu_utilization_low_period_seconds
  cpu_utilization_low_statistic           = var.cpu_utilization_low_statistic
  cpu_utilization_low_threshold_percent   = var.cpu_utilization_low_threshold_percent
}

data "template_file" "userdata" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/userdata.tpl")

  vars = {
    cluster_endpoint           = var.cluster_endpoint
    certificate_authority_data = var.cluster_certificate_authority_data
    cluster_name               = var.cluster_name
    bootstrap_extra_args       = var.bootstrap_extra_args
  }
}

data "aws_iam_instance_profile" "default" {
  count = var.enabled && local.use_existing_instance_profile ? 1 : 0
  name  = var.aws_iam_instance_profile_name
}

data "template_file" "config_map_aws_auth" {
  count    = local.enabled ? 1 : 0
  template = file("${path.module}/config_map_aws_auth.tpl")

  vars = {
    aws_iam_role_arn = local.use_existing_instance_profile ? join("", data.aws_iam_instance_profile.default.*.role_arn) : join("", aws_iam_role.default.*.arn)
  }
}