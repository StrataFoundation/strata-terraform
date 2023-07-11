module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "${var.cluster_name}-${var.stage}"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa                     = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" 
    }
  }

  cluster_addons = {
    # aws eks describe-addon-versions --addon-name coredns
    coredns = {
      addon_version     = "v1.9.3-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    # aws eks describe-addon-versions --addon-name kube-proxy
    kube-proxy = {
      addon_version      = "v1.25.6-eksbuild.1"
      resolve_conflicts  = "OVERWRITE"
    }
    # aws eks describe-addon-versions --addon-name vpc-cni
    vpc-cni = {
      addon_version        = "v1.12.2-eksbuild.1"
      resolve_conflicts    = "OVERWRITE"
      configuration_values = jsonencode({
        init = {
          env = {
            DISABLE_TCP_EARLY_DEMUX = "true"
          }
        }
        env = {
          ENABLE_POD_ENI = "true"
        }
      })
    }
    # aws eks describe-addon-versions --addon-name aws-ebs-csi-driver
    aws-ebs-csi-driver = {
      addon_version = "v1.20.0-eksbuild.1"
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
