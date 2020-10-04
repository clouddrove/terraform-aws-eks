resource "aws_eks_node_group" "node_group" {
count             = "${length(var.node_groups)}"
  cluster_name  =  var.name
  node_group_name = "${element(var.node_groups,count.index)}"
  node_role_arn = var.aws_iam_role_arn  
  subnet_ids    = var.subnet_ids

  scaling_config {
    desired_size = "${element(var.desired_size,count.index)}"
    max_size     = "${element(var.max_size,count.index)}"
    min_size     = "${element(var.min_size,count.index)}"
  }
  
  }
