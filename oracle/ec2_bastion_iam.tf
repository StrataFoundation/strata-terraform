# Create IAM role to server as bastion instance profile to facilitate logging by cw agent
# Needed for ssh access slack alerting 
resource "aws_iam_role" "bastion_cw_agent_role" {
  name        = "bastion-cloudwatch-agent-role"
  description = "IAM role for EC2 Instance Profile to facilitate logging by CloudWatch Agent"

  managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# EC2 Instance Profile to facilitate logging by CloudWatch Agent on bastion
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile_for_cw_agent"
  role = aws_iam_role.bastion_cw_agent_role.name
}