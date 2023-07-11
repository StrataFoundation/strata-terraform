module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name    = "${var.cluster_name}-${var.stage}"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults

  enable_irsa = true

  # Make sure addon_version aligns with k8s/eks version!
  cluster_addons = {
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
    coredns = {
      addon_version               = "v1.9.3-eksbuild.5"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
    kube-proxy = {
      addon_version               = "v1.25.6-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
    vpc-cni = {
      addon_version               = "v1.13.2-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    # aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
    aws-ebs-csi-driver = {
      addon_version               = "v1.20.0-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  # Remove this tag to allow the aws lb to target a single sg using the tag
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2258
  node_security_group_tags = var.node_security_group_tags

  eks_managed_node_groups = local.node_types[var.env]

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
