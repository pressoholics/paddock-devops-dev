locals {
  use_default_zone = var.route53_zone_id == ""
}

resource "aws_route53_record" "default" {
  count    = var.route53_enabled && local.use_default_zone ? 1 : 0
  zone_id  = "Z0418640L39TXNEENWHC"
  name     = local.default_domain_name
  type     = "CNAME"
  ttl      = "300"
  records  = [aws_cloudfront_distribution.default.domain_name]
  provider = aws.jam3devops
}

resource "aws_route53_record" "custom" {
  count    = var.route53_enabled && (local.use_default_zone == false) ? 1 : 0
  zone_id  = var.route53_zone_id
  name     = var.cloudfront_domain
  type     = "A"
  provider = aws.project-account
  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = true
  }
}
