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

  # Allow setting access permissions to the eks cluster (e.g., who can run kubectl commands) via aws-auth configmap
  manage_aws_auth_configmap = true
  create_aws_auth_configmap = true

  # Allow all users in an AWS environment with the "AWSAdministratorAccess" role to run kubectl commands
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${tolist(data.aws_iam_roles.admin_role.names)[0]}"
      username = "AWSAdministratorAccess:{{SessionName}}"
      groups = [
        "system:masters",
      ]
    }
  ]
}
