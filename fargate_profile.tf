module "fargate" {
  source = "./node_group/fargate_profile"

  name             = var.name
  environment      = var.environment
  label_order      = var.label_order
  enabled          = var.enabled
  fargate_enabled  = var.fargate_enabled
  cluster_name     = aws_eks_cluster.default[0].name
  fargate_profiles = var.fargate_profiles
  subnet_ids       = var.subnet_ids

}