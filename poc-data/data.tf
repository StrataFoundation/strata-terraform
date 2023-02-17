data "aws_caller_identity" "current" {}

data "aws_iam_policy" "lambda_required_iam_policy" {
  name = "AWSLambdaVPCAccessExecutionRole"
}