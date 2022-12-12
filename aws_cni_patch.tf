resource "null_resource" "aws_cni_patch" {
  triggers = {
    cluster_name  = local.cluster_name
    node_sg       = module.eks.node_security_group_id
    intra_subnets = join(",", module.vpc.intra_subnets)
    content       = file("${path.module}/scripts/aws_cni_patch.sh")
  }

  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      REGION       = var.aws_region
    }
    command     = "${path.cwd}/scripts/aws_cni_patch.sh"
    interpreter = ["bash"]
  }

  depends_on = [
    module.eks
  ]
}