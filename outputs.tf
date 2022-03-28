# Cloudfront

output "cloudfront_distribution_domain_name" {
  value = module.spa.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_alias" {
  value = module.spa.cloudfront_distribution_alias
}

output "cloudfront_distribution_id" {
  value = module.spa.cloudfront_distribution_id
}

# IAM

output "deployment_iam_user_arn" {
  value = module.spa.deployment_iam_user_arn
}

output "deployment_iam_user_access_key" {
  value = module.spa.deployment_iam_user_access_key
}

output "deployment_iam_user_secret_key" {
  value = module.spa.deployment_iam_user_secret_key
  # sensitive = true
}

# S3 Origin

output "origin_s3_bucket_name" {
  value = module.spa.origin_s3_bucket_name
}

# Security Headers

output "security_headers_enabled" {
  value = module.spa.security_headers_enabled
}

# Basic Auth

output "basic_auth_enabled" {
  value = module.spa.basic_auth_enabled
}

output "basic_auth_username" {
  value = module.spa.basic_auth_username
}

output "basic_auth_password" {
  value = module.spa.basic_auth_password
}

