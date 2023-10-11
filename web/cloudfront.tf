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
    min_ttl                  = 31536000 // 365 days
    max_ttl                  = 31536000 
    default_ttl              = 31536000 

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
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
}