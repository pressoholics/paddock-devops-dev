resource "aws_acm_certificate" "cloud_jam3_net" {
  provider          = aws.us-east-1
  domain_name       = local.default_domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cloud_jam3_net" {
  provider        = aws.jam3devops
  name            = tolist(aws_acm_certificate.cloud_jam3_net.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cloud_jam3_net.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.cloud_jam3_net.domain_validation_options)[0].resource_record_type
  ttl             = 60
  zone_id         = "Z0418640L39TXNEENWHC"
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cloud_jam3_net" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cloud_jam3_net.arn
  validation_record_fqdns = [aws_route53_record.cloud_jam3_net.fqdn]
}
