resource "aws_security_group" "ec2_bastion_security_group" {
  name        = "ec2-bastion-security-group"
  description = "Security group restricting SSH access to bastion for fixed IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ec2_bastion_access_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-bastion-security-group"
  }
}