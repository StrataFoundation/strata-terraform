# resource "kubernetes_service_account" "lb" {
#   metadata {
#     name      = "lb"
#     namespace = "default"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.lb.arn,
#       "meta.helm.sh/release-name" = "aws-load-balancer-controller",
#       "meta.helm.sh/release-namespace" = "default",
#     }
#     labels = {
#       "app.kubernetes.io/managed-by" = "Helm",
#     }
#   }
#   automount_service_account_token = true
# }

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
  automount_service_account_token = true
}
