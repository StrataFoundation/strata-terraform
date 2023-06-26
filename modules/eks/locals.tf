locals {
  node_types = {
    true = {
      medium_group = {
        name                         = var.cluster_node_name
        instance_types               = [var.eks_instance_type]
        min_size                     = var.cluster_min_size
        max_size                     = var.cluster_max_size
        desired_size                 = var.cluster_desired_size
        vpc_security_group_ids       = [
          aws_security_group.small_node_group.id
        ]
        iam_role_additional_policies = { 
          AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
        }
      }
      
      migration_group = {
        name                   = "migration-node"
        instance_types         = ["r5.xlarge"]
        min_size               = 1
        max_size               = 1
        desired_size           = 1
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
        taints                 = [
          {
            key    = "migration_workload"
            value  = "true"
            effect = "NO_SCHEDULE"
          }
        ]
      }
    }
    false = {
      medium_group = {
        name                   = var.cluster_node_name
        instance_types         = [var.eks_instance_type]
        min_size               = var.cluster_min_size
        max_size               = var.cluster_max_size
        desired_size           = var.cluster_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
        iam_role_additional_policies = { 
          AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
        }
      }
    }
  }
}