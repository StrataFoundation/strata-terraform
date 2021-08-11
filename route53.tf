resource "aws_route53_record" "team_wumbo" {
  for_each = {
    for dvo in aws_acm_certificate.team_wumbo.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate" "team_wumbo" {
  domain_name       = "*.teamwumbo.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_acm_certificate_validation" "team_wumbo" {
  certificate_arn         = aws_acm_certificate.team_wumbo.arn
  validation_record_fqdns = [for record in aws_route53_record.team_wumbo : record.fqdn]
}

