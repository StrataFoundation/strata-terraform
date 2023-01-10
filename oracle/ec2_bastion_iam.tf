# Create IAM role to server as bastion instance profile to facilitate logging by cw agent
# Needed for ssh access slack alerting 
resource "aws_iam_role" "bastion_cw_agent_role" {
  name        = "bastion-cloudwatch-agent-role"
  description = "EC2 IAM Instance Profile to facilitate logging by CloudWatch Agent"

  managed_managed_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

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