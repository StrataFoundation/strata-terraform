resource "aws_instance" "bastion" {
  # Instance
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.ec2_bastion_ssh_key_name
  user_data     = "${file("${path.module}/scripts/ec2_bastion_user_data.sh")}"

  # VPC & Networking
  availability_zone = var.aws_azs[0]
  subnet_id         = module.vpc.public_subnets[0]
  private_ip        = var.ec2_bastion_private_ip

  # Security
  vpc_security_group_ids = [
    aws_security_group.rds_access_security_group.id, 
    aws_security_group.ec2_bastion_security_group.id
  ]

  # Storage 
  root_block_device {
    volume_size           = "100"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "bastion"
  }

  depends_on = [
    aws_iam_role.bastion_cw_agent_role
  ]
}

resource "aws_eip" "bastion_eip" {
  vpc                       = true
  instance                  = aws_instance.bastion.id
  associate_with_private_ip = var.ec2_bastion_private_ip
  depends_on                = [module.vpc.igw_id]
}