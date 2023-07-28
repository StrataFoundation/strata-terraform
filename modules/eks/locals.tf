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
        labels = {
          nodegroup-type = "medium"
          node-type      = "medium"
        }
      }
      spot_group_a = {
        name                   = "spot-group-a"
        capacity_type          = "SPOT"
        subnet_ids             = var.subnet_ids[0]
        instance_types         = ["r5.large", "r4.large"]
        min_size               = var.cluster_spot_min_size
        max_size               = var.cluster_spot_max_size
        desired_size           = var.cluster_spot_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
        labels = {
          nodegroup-type = "spot-a"
          node-type      = "spot-a"
        }
        # Aligned with Lighter executor pod definition
        # https://github.com/exacaster/lighter/blob/master/k8s/executor_pod_template.yaml
        taints = [ 
          {
            key    = "dedicated"
            value  = "spot-a"
            effect = "NO_SCHEDULE"
          }
        ]
      }
      spot_group_b = {
        name                   = "spot-group-b"
        capacity_type          = "SPOT"
        subnet_ids             = var.subnet_ids[1]
        instance_types         = ["r5.large", "r4.large"]
        min_size               = var.cluster_spot_min_size
        max_size               = var.cluster_spot_max_size
        desired_size           = var.cluster_spot_desired_size
        vpc_security_group_ids = [
          aws_security_group.small_node_group.id
        ]
        labels = {
          nodegroup-type = "spot-b"
          node-type      = "spot-b"
        }
        # Aligned with Lighter executor pod definition
        # https://github.com/exacaster/lighter/blob/master/k8s/executor_pod_template.yaml
        taints = [ 
          {
            key    = "dedicated"
            value  = "spot-b"
            effect = "NO_SCHEDULE"
          }
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