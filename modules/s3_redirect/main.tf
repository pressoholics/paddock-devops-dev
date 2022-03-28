variable "host" {
  description = "Redirect host"
}

variable "domain" {
  description = "Domain name of the redirect host"
}

variable "redirect" {
  description = "URL that should be redirected to"
}

# Route53 Zone
data "aws_route53_zone" "domain" {
  name         = var.host
  private_zone = false
}

# S3
resource "aws_s3_bucket" "redirect" {
  bucket        = var.domain
  acl           = "private"
  force_destroy = true

  website {
    redirect_all_requests_to = var.redirect
  }
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_type
  zone_id = data.aws_route53_zone.domain.id
  records = [tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

# Cloudfront
resource "aws_cloudfront_distribution" "redirect" {
  http_version = "http2"
  comment      = "${var.domain}-redirect"

  origin {
    origin_id   = "origin-${var.domain}"
    domain_name = aws_s3_bucket.redirect.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "User-Agent"
      value = base64sha512("REFER-SECRET-19265125-${var.domain}-52865926")
    }
  }

  enabled = true
  aliases = [var.domain]

  price_class = "PriceClass_100"

  default_cache_behavior {
    target_origin_id = "origin-${var.domain}"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

# Route53 Records
resource "aws_route53_record" "domain" {
  name    = var.domain
  zone_id = data.aws_route53_zone.domain.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = true
  }
}
