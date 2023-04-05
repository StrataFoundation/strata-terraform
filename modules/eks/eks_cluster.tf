module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name    = "${var.cluster_name}-${var.stage}"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults

  enable_irsa = true

  # Remove this tag to allow the aws lb to target a single sg using the tag
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2258
  node_security_group_tags = var.node_security_group_tags

  eks_managed_node_groups = {
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

    migration_group = var.node_group_for_migration ? {
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

    } : null
  }

  # Allow setting access permissions to the eks cluster (e.g., who can run kubectl commands) via aws-auth configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  # Allow all users in an AWS environment with the "AWSAdministratorAccess" role to run kubectl commands
  aws_auth_roles = var.manage_aws_auth_configmap ? [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${tolist(data.aws_iam_roles.admin_role.names)[0]}"
      username = "AWSAdministratorAccess:{{SessionName}}"
      groups = [
        "system:masters",
      ]
    }
  ] : []
}
