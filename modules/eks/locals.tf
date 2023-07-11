locals {
  node_types = {
    poc-data = {
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
        labels = {
          nodegroup-type = "medium"
          node-type      = "medium"
        }
      }
      job_group = {
        name                         = var.cluster_job_node_name
        instance_types               = [var.eks_job_instance_type]
        min_size                     = var.cluster_job_min_size
        max_size                     = var.cluster_job_max_size
        desired_size                 = var.cluster_job_desired_size
        vpc_security_group_ids       = [
          aws_security_group.small_node_group.id
        ]
        iam_role_additional_policies = {
          AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
        }
        labels = {
          nodegroup-type = "job"
          node-type      = "job"
        }
      }
      spot_group = {
        name                         = var.cluster_spot_node_name
        capacity_type                = "SPOT"
        instance_types               = [var.eks_spot_instance_type]
        min_size                     = var.cluster_spot_min_size
        max_size                     = var.cluster_spot_max_size
        desired_size                 = var.cluster_spot_desired_size
        vpc_security_group_ids       = [
          aws_security_group.small_node_group.id
        ]
        iam_role_additional_policies = {
          AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
        }
        labels = {
          nodegroup-type        = "spot"
          node-type             = "spot"
        }
        # Aligned with Lighter executor pod definition
        # https://github.com/exacaster/lighter/blob/master/k8s/executor_pod_template.yaml
        taints = [ 
          {
            key    = "dedicated"
            value  = "spark"
            effect = "NO_SCHEDULE"
          }
        ]
      }
    }
    oracle = {
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
    }
    web = {      
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
    }
  }
}