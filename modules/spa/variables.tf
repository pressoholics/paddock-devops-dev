variable "region" {
  type        = string
  description = "AWS region"
}

variable "role_arn" {
  type        = string
  description = "AWS IAM role"
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = string
  description = "Environment, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}


#Cloudfront

variable "cloudfront_price_class" {
  type        = string
  description = "Cloudfront price class.  Valid values are PriceClass_100, PriceClass_200, PriceClass_All"
  default     = "PriceClass_All"
}

variable "cloudfront_wait_for_deployment" {
  type        = bool
  description = "Indicates whether Terraform should wait for Cloudfront distribution changes to propagate"
  default     = true
}

variable "cloudfront_domain" {
  type        = string
  description = "Domain name for Cloudfront distribution"
  default     = ""
}

variable "cloudfront_domain_aliases" {
  type        = list(string)
  description = "Domain aliases for Cloudfront distribution"
  default     = []
}

variable "cloudfront_acm_certificate_arn" {
  type        = string
  description = "Amazon Certificate Manager certificate ARN to use with CloudFront. Must be in us-east-1"
  default     = ""
}

variable "cloudfront_geo_restricted_locations" {
  type        = list(string)
  description = "List of 2-letter country codes for Cloudfront geolocation restriction"
  default     = []
}

variable "cloudfront_geo_restriction_type" {
  type        = string
  description = "Cloudfront geolocation restriction type. Valid values are none, whitelist, blacklist"
  default     = "none"
}

variable "cloudfront_log_prefix" {
  type        = string
  description = "Cloudfront distribution logging S3 bucket prefix"
  default     = "cloudfront-access"
}

#S3
variable "logs_s3_force_destroy" {
  type        = bool
  description = "Indicates whether the S3 log bucket can be destroyed without error if the bucket is not empty"
  default     = false
}

variable "origin_s3_force_destroy" {
  type        = bool
  description = "Indicates whether the S3 origin bucket can be destroyed without error if bucket is not empty"
  default     = false
}

#Lambda Security Headers
variable "lambda_security_headers_enabled" {
  type        = bool
  description = "Determines whether the security headers Lambda is added to the CloudFront distribution"
  default     = false
}

variable "lambda_security_headers_default_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_image_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_style_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_font_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_media_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_connect_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_script_source" {
  type    = list(string)
  default = []
}

variable "lambda_security_headers_csp_report_only" {
  type    = bool
  default = false
}

variable "lambda_security_headers_allow_x_frame" {
  type    = bool
  default = false
}

#Lambda Basic Auth
variable "lambda_basic_auth_enabled" {
  type        = bool
  description = "Determines whether the basic authentication Lambda is added to the CloudFront distribution"
  default     = false
}

variable "lambda_basic_auth_username" {
  type        = string
  description = "String to use as username for basic authentication"
  default     = "preview"
}

variable "lambda_basic_auth_password" {
  type        = string
  description = "String to use as password for basic authentication"
  default     = "preview"
}

variable "lambda_basic_auth_token" {
  type        = string
  description = "Token for basic auth whitelisting"
  default     = ""
}

variable "lambda_basic_auth_ip_whitelist" {
  type        = list(string)
  description = "List of IPs to whitelist from basic auth"
  default     = []
}

#SNS
variable "alarm_email_address" {
  type        = string
  description = "Email address to receive CloudFront metric alarm notifications"
}

# Route 53
variable "route53_enabled" {
  type        = bool
  description = "Enables the creation of DNS records in Route53.  Route53 zone specified in variable route53_zone_id."
  default     = true
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID"
  default     = ""
}

# S3 Origin
variable "origin_s3_log_prefix" {
  type        = string
  description = "S3 Origin bucket log prefix"
  default     = "origin-server-access/"
}

# WAF
variable "waf_trusted_cidrs" {
  type        = list(string)
  description = "Trusted list of CIDR networks for WAF IP set"
  default     = []
}

variable "waf_rate_limit" {
  type        = number
  description = "WAF rate limit.  Per IP in 5 minute intervals"
  default     = 5000
}

# Cloud Trail
variable "cloudtrail_enabled" {
  type        = bool
  description = "Determines if cloud trail is enabled"
  default     = true
}

variable "cloudtrail_s3_prefix" {
  type        = string
  description = "Prefix used by cloudtrail on the logs bucket"
  default     = "cloud_trail"
}
