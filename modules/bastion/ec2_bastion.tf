resource "aws_instance" "bastion" {
  # Instance
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.ec2_bastion_ssh_key_name
  user_data     = var.user_data ? "${file("${var.user_data}")}" : null

  # VPC & Networking
  availability_zone = var.aws_az
  subnet_id         = var.public_subnet_id
  private_ip        = var.ec2_bastion_private_ip

  # Security
  vpc_security_group_ids = concat(
    [aws_security_group.ec2_bastion_security_group.id],
    var.security_group_ids
  )
  iam_instance_profile = var.cloudwatch_ssh_denied_monitoring ? aws_iam_instance_profile.bastion_instance_profile.name : null

  # Storage 
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "bastion"
  }

  depends_on = [aws_iam_role.bastion_cw_agent_role]
}