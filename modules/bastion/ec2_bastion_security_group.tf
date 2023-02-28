resource "aws_security_group" "ec2_bastion_security_group" {
  name        = "ec2-bastion-security-group"
  description = "Security group restricting access to Bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ec2-bastion-security-group"
  }
}

resource "aws_security_group_rule" "ec2_bastion_security_group_ingress_rule_1" {
  type              = "ingress"
  description       = "Allow access SSH from Noah or Darwin"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ec2_bastion_access_ips
  security_group_id = aws_security_group.ec2_bastion_security_group.id
}

resource "aws_security_group_rule" "ec2_bastion_security_group_ingress_rule_2" {
  count             = var.stage == "prod" ? 1 : 0 

  type              = "ingress"
  description       = "UPD IPv4 access for Tailscale"
  from_port         = 41641
  to_port           = 41641
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_bastion_security_group.id
}

resource "aws_security_group_rule" "ec2_bastion_security_group_ingress_rule_3" {
  count             = var.stage == "prod" ? 1 : 0 

  type              = "ingress"
  description       = "UPD IPv6 access for Tailscale"
  from_port         = 41641
  to_port           = 41641
  protocol          = "udp"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.ec2_bastion_security_group.id
}

resource "aws_security_group_rule" "ec2_bastion_security_group_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_bastion_security_group.id
}
