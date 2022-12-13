module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }


  # Remove this tag to allow the aws lb to target a single sg using the tag
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2258
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  # This rule on the node security group appears to be required to let pods
  # with the rds-access-security-group sg communicate with the open internet
  node_security_group_additional_rules  = {
    ingress_allow_access_fron_rds_access_sg = {
      type                          = "ingress"
      from_port                     = 0
      to_port                       = 0
      protocol                      = "-1"
      source_security_group_id      = aws_security_group.rds_access_security_group.id
      description                   = "Allow access from rds-access-security-group"
    }
  }

  eks_managed_node_groups = {
    medium_group = {
      name = "small-node-group"

      instance_types = [var.instance_type]

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
