resource "aws_security_group" "small_node_group" {
  name_prefix = "${var.cluster_node_name}_group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [var.cidr_block]
  }
}
