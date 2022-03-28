terraform {
  required_version = "~> 1.0.11"
  required_providers {
    aws      = "~> 3.67"
    null     = "~> 2.0"
    random   = "~> 2.2"
    archive  = "~> 1.3.0"
    template = "~> 2.1"
  }

  # Uncomment and adjust if using Terraform with local execution mode
  #  backend "remote" {
  #    hostname     = "app.terraform.io"
  #    organization = "jam3"
  #    workspace {
  #      name = "{{ TF_CLOUD_WORKSPACE_NAME }}"
  #    }
  #  }

}

module "spa" {
  source = "./modules/spa"
  providers = {
    aws                 = aws
    aws.project-account = aws.project-account
    aws.us-east-1       = aws.us-east-1
    aws.jam3devops      = aws.jam3devops
  }

  role_arn            = var.role_arn
  region              = var.region
  namespace           = var.namespace
  environment         = var.environment
  name                = var.name
  delimiter           = var.delimiter
  attributes          = var.attributes
  tags                = var.tags
  alarm_email_address = var.alarm_email_address

  ### Lambda ###
  lambda_basic_auth_enabled      = var.lambda_basic_auth_enabled
  lambda_basic_auth_username     = var.lambda_basic_auth_username
  lambda_basic_auth_password     = var.lambda_basic_auth_password
  lambda_basic_auth_token        = var.lambda_basic_auth_token
  lambda_basic_auth_ip_whitelist = var.lambda_basic_auth_ip_whitelist

  ### Lambda - Security Headers ###
  lambda_security_headers_enabled         = var.lambda_security_headers_enabled
  lambda_security_headers_default_source  = var.lambda_security_headers_default_source
  lambda_security_headers_image_source    = var.lambda_security_headers_image_source
  lambda_security_headers_style_source    = var.lambda_security_headers_style_source
  lambda_security_headers_font_source     = var.lambda_security_headers_font_source
  lambda_security_headers_media_source    = var.lambda_security_headers_media_source
  lambda_security_headers_connect_source  = var.lambda_security_headers_connect_source
  lambda_security_headers_script_source   = var.lambda_security_headers_script_source
  lambda_security_headers_csp_report_only = var.lambda_security_headers_csp_report_only
  lambda_security_headers_allow_x_frame   = var.lambda_security_headers_allow_x_frame

  cloudfront_domain                   = var.cloudfront_domain
  cloudfront_domain_aliases           = var.cloudfront_domain_aliases
  cloudfront_price_class              = var.cloudfront_price_class
  cloudfront_wait_for_deployment      = var.cloudfront_wait_for_deployment
  cloudfront_acm_certificate_arn      = var.cloudfront_acm_certificate_arn
  cloudfront_geo_restricted_locations = var.cloudfront_geo_restricted_locations
  cloudfront_geo_restriction_type     = var.cloudfront_geo_restriction_type
  cloudfront_log_prefix               = var.cloudfront_log_prefix

  origin_s3_force_destroy = var.origin_s3_force_destroy

  logs_s3_force_destroy = var.logs_s3_force_destroy

  route53_enabled = var.route53_enabled
  route53_zone_id = var.route53_zone_id

  origin_s3_log_prefix = var.origin_s3_log_prefix

  waf_trusted_cidrs = var.waf_trusted_cidrs
  waf_rate_limit    = var.waf_rate_limit

  cloudtrail_enabled = var.cloudtrail_enabled
}
