locals {
  node_types = {
    poc-data = {
      medium_group = {
        name                   = var.cluster_node_name
        instance_types         = [var.eks_instance_type]
        min_size               = var.cluster_min_size
        max_size               = var.cluster_max_size
        desired_size           = var.cluster_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
      }
      job_group = {
        name                   = var.cluster_job_node_name
        instance_types         = [var.eks_job_instance_type]
        min_size               = var.cluster_job_min_size
        max_size               = var.cluster_job_max_size
        desired_size           = var.cluster_job_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
      }
    }
    oracle = {
      medium_group = {
        name                   = var.cluster_node_name
        instance_types         = [var.eks_instance_type]
        min_size               = var.cluster_min_size
        max_size               = var.cluster_max_size
        desired_size           = var.cluster_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
      }
    }
    web = {
      medium_group = {
        name                   = var.cluster_node_name
        instance_types         = [var.eks_instance_type]
        min_size               = var.cluster_min_size
        max_size               = var.cluster_max_size
        desired_size           = var.cluster_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
      }
    }
  }
}