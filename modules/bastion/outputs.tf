output "bastion_eip" {
  value = aws_eip.bastion_eip.public_ip
}