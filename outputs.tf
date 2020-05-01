output "kubeconfig" {
  value       = module.eks_cluster.kubeconfig
  description = "`kubeconfig` configuration to connect to the cluster using `kubectl`. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#configuring-kubectl-for-eks."
}

output "config_map_aws_auth" {
  value       = module.eks_workers.config_map_aws_auth
  description = "Kubernetes ConfigMap configuration to allow the worker nodes to join the EKS cluster. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#required-kubernetes-configuration-to-join-worker-nodes."
}

output "eks_cluster_security_group_id" {
  value       = module.eks_cluster.security_group_id
  description = "ID of the EKS cluster Security Group."
}

output "eks_cluster_security_group_arn" {
  value       = module.eks_cluster.security_group_arn
  description = "ARN of the EKS cluster Security Group."
}

output "eks_cluster_security_group_name" {
  value       = module.eks_cluster.security_group_name
  description = "Name of the EKS cluster Security Group."
}

output "eks_cluster_id" {
  value       = module.eks_cluster.eks_cluster_id
  description = "The name of the cluster."
}

output "eks_cluster_arn" {
  value       = module.eks_cluster.eks_cluster_arn
  description = "The Amazon Resource Name (ARN) of the cluster."
}

output "eks_cluster_certificate_authority_data" {
  value       = module.eks_cluster.eks_cluster_certificate_authority_data
  description = "The base64 encoded certificate data required to communicate with the cluster."
}

output "eks_cluster_endpoint" {
  value       = module.eks_cluster.eks_cluster_endpoint
  description = "The endpoint for the Kubernetes API server."
}

output "eks_cluster_version" {
  value       = module.eks_cluster.eks_cluster_version
  description = "The Kubernetes server version of the cluster."
}

output "workers_launch_template_id" {
  value       = module.eks_workers.launch_template_id
  description = "ID of the launch template."
}

output "workers_launch_template_arn" {
  value       = module.eks_workers.launch_template_arn
  description = "ARN of the launch template."
}

output "workers_autoscaling_group_id" {
  value       = module.eks_workers.autoscaling_group_id
  description = "The AutoScaling Group ID."
}

output "workers_autoscaling_group_name" {
  value       = module.eks_workers.autoscaling_group_name
  description = "The AutoScaling Group name."
}

output "workers_autoscaling_group_arn" {
  value       = module.eks_workers.autoscaling_group_arn
  description = "ARN of the AutoScaling Group."
}

output "workers_autoscaling_group_min_size" {
  value       = module.eks_workers.autoscaling_group_min_size
  description = "The minimum size of the AutoScaling Group."
}

output "workers_autoscaling_group_max_size" {
  value       = module.eks_workers.autoscaling_group_max_size
  description = "The maximum size of the AutoScaling Group."
}

output "workers_autoscaling_group_desired_capacity" {
  value       = module.eks_workers.autoscaling_group_desired_capacity
  description = "The number of Amazon EC2 instances that should be running in the group."
}

output "workers_autoscaling_group_default_cooldown" {
  value       = module.eks_workers.autoscaling_group_default_cooldown
  description = "Time between a scaling activity and the succeeding scaling activity."
}

output "workers_autoscaling_group_health_check_grace_period" {
  value       = module.eks_workers.autoscaling_group_health_check_grace_period
  description = "Time after instance comes into service before checking health."
}

output "workers_autoscaling_group_health_check_type" {
  value       = module.eks_workers.autoscaling_group_health_check_type
  description = "`EC2` or `ELB`. Controls how health checking is done."
}

output "workers_security_group_id" {
  value       = module.eks_workers.security_group_id
  description = "ID of the worker nodes Security Group."
}

output "workers_security_group_arn" {
  value       = module.eks_workers.security_group_arn
  description = "ARN of the worker nodes Security Group."
}

output "workers_security_group_name" {
  value       = module.eks_workers.security_group_name
  description = "Name of the worker nodes Security Group."
}

output "eks_node_group_id" {
  value       = module.eks_workers.eks_node_group_id
  description = "EKS Cluster name and EKS Node Group name separated by a colon"
}

output "eks_node_group_arn" {
  value       = module.eks_workers.eks_node_group_arn
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
}

output "eks_node_group_resources" {
  value       = module.eks_workers.eks_node_group_resources
  description = "List of objects containing information about underlying resources of the EKS Node Group"
}

output "eks_node_group_status" {
  value       = module.eks_workers.eks_node_group_status
  description = "Status of the EKS Node Group"
}

output "eks_fargate_arn" {
  value       = module.eks_workers.eks_fargate_arn
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile."
}

output "eks_fargate_id" {
  value       = module.eks_workers.eks_fargate_id
  description = "EKS Cluster name and EKS Fargate Profile name separated by a colon (:)."
}

output "tags" {
  value       = module.eks_cluster.tags
  description = "A mapping of tags to assign to the resource."
}