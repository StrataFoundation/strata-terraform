module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "small-node-group"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = var.cluster_max_size
      desired_size = var.cluster_desired_size

      pre_bootstrap_user_data = <<-EOT
      EOT

      vpc_security_group_ids = [
        aws_security_group.small_node_group.id
      ]
    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

module "lb-controller" {
  source       = "Young-ook/eks/aws//modules/lb-controller"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  helm = {
    vars = {
      clusterName = module.eks.cluster.name
    }
  }
}
