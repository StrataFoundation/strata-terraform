resource "aws_iam_policy" "ecr_access_iam_policy" {
  name   = "ECR-access-iam-policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr-public:CompleteLayerUpload",
          "ecr-public:GetAuthorizationToken",
          "ecr-public:UploadLayerPart",
          "ecr-public:InitiateLayerUpload",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:PutImage",
          "sts:GetServiceBearerToken",
          "ecr-public:DescribeRegistries"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
