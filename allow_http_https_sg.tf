resource "aws_security_group" "allow_http_https_inbound" {
  name = "allow_tls"
  description = "Allow tls Inbound Public Traffic"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_egress" {
  security_group_id = aws_security_group.allow_http_https_inbound.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "all_ingress_tls" {
  type = "ingress"
  security_group_id = aws_security_group.allow_http_https_inbound.id
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "all_ingress_http" {
  type = "ingress"
  security_group_id = aws_security_group.allow_http_https_inbound.id
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-8080"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = var.public_subnets
}
