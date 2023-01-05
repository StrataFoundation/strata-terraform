# During deployment of the EKS cluster, the aws-cni addon gets applied by default. 
# However, in order to allow for pod-level security groups, a patch needs to be applied to the 
# aws-cni addon. To do so, the "null_resource" is used to execute a bash script to apply the patch.
# resource "null_resource" "aws_cni_patch" {
#   triggers = {
#     cluster_name  = local.cluster_name
#     node_sg       = module.eks.node_security_group_id
#     intra_subnets = join(",", module.vpc.intra_subnets)
#     content       = file("${path.module}/scripts/aws_cni_patch.sh")
#   }

#   provisioner "local-exec" {
#     environment = {
#       CLUSTER_NAME = self.triggers.cluster_name
#       REGION       = var.aws_region
#     }
#     command     = "${path.cwd}/scripts/aws_cni_patch.sh"
#     interpreter = ["bash"]
#   }

#   depends_on = [
#     module.eks
#   ]
# }