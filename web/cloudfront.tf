resource "aws_cloudfront_distribution" "metadata_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  aliases         = var.cf_origin_aliases
  http_version    = "http2and3"

  origin {
    domain_name = data.aws_lb.lb.dns_name
    origin_id   = data.aws_lb.lb.dns_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 30
      origin_read_timeout      = 60
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = data.aws_lb.lb.dns_name
    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html#managed-origin-request-policy-all-viewer
    cache_policy_id          = aws_cloudfront_cache_policy.metadata_distribution_cache_policy.id
  }

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_cloudfront_cache_policy.metadata_distribution_cache_policy]
}

resource "aws_cloudfront_cache_policy" "metadata_distribution_cache_policy" {
  name        = "metadata-cache-policy"
  comment     = "Cache policy for entities.nft.test-helium.com"
  default_ttl = 31536000 // 1 year
  max_ttl     = 31536000
  min_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    } 
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_iam_role" "invalidation_role" {
  name        = "invalidation-role"
  description = "IAM Role for a K8s pod to assume to invalidate CloudFront cache and access public monitoring RDS via the monitoring user"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${module.eks[0].oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${module.eks[0].oidc_provider}:sub" = "system:serviceaccount:helium:invalidation-role"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cloudfront_invalidation_policy" {
  name   = "cloudfront-invalidation-policy" 
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "cloudfront:CreateInvalidation"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudfront_invalidation_policy_attachment" {
  role       = aws_iam_role.invalidation_role.id
  policy_arn = aws_iam_policy.cloudfront_invalidation_policy.arn
}

resource "aws_iam_role_policy_attachment" "public_monitoring_rds_access_policy_attachment" {
  role       = aws_iam_role.invalidation_role.id
  policy_arn = data.aws_iam_policy.public_monitoring_rds_access_policy.arn
}