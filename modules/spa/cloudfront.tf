locals {
  s3_origin_id          = "S3ORIGIN"
  s3_origin_domain_name = "${aws_s3_bucket.origin.id}.${aws_s3_bucket.origin.website_domain}"
  use_default_domain    = var.cloudfront_domain == ""
  use_default_cert      = var.cloudfront_acm_certificate_arn == ""
  default_domain_name   = "${var.environment}.${var.name}.${var.namespace}.cloud.jam3.net"
}

# Primary CloudFront distribution
resource "aws_cloudfront_distribution" "default" {
  depends_on = [
    aws_s3_bucket.logs,
    aws_wafv2_web_acl.default,
    aws_cloudfront_function.default_viewer_request,
    module.lambda_default_origin_response
  ]
  wait_for_deployment = var.cloudfront_wait_for_deployment
  enabled             = true
  is_ipv6_enabled     = true
  #aliases             = local.use_default_domain ? [local.default_domain_name] : concat([var.cloudfront_domain], var.cloudfront_domain_aliases)
  comment             = module.label.id
  tags                = module.label.tags
  price_class         = var.cloudfront_price_class
  web_acl_id          = aws_wafv2_web_acl.default.arn
  default_root_object = "index.html"
  
  # Commenting local-exec due to the error mentioned when Terraform executes a local-exec on Terraform Cloud
  # Error details available at https://app.terraform.io/app/jam3/workspaces/eduardo-test/runs/run-F1kAPBTxkcyuko53
  # Create invalidation
  #provisioner "local-exec" {
  #  command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*'"
  #}
    

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restricted_locations
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = var.cloudfront_log_prefix
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    domain_name = local.s3_origin_domain_name
    origin_id   = local.s3_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    custom_header {
      name  = "Referer"
      value = random_id.referer.b64_std
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    smooth_streaming       = false

    /* ***** Adding ttl to set Use Origin Cache Headers. Issue: https://github.com/hashicorp/terraform-provider-aws/issues/19382 ***** */
    default_ttl = 86400
    min_ttl     = 0
    max_ttl     = 31536000
    /* end */

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.default_viewer_request.arn
    }

    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = module.lambda_default_origin_response.function_arn
      include_body = false
    }
  }
}
