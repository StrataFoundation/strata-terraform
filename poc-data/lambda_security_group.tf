resource "aws_security_group" "s3_replicator_lambda_security_group" {
  name        = "s3-replicator-lambda-security-group"
  description = "Security group for S3 Replicator Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "s3-replicator-lambda-security-group"
  }
}
