# Cloudfront

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.default.domain_name
}

output "cloudfront_distribution_alias" {
  value = local.use_default_domain ? local.default_domain_name : ""
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.default.id
}

# IAM

output "deployment_iam_user_arn" {
  value = aws_iam_user.cd.arn
}

output "deployment_iam_user_access_key" {
  value = aws_iam_access_key.cd.id
}

output "deployment_iam_user_secret_key" {
  value = aws_iam_access_key.cd.secret
}

# S3 Origin

output "origin_s3_bucket_name" {
  value = aws_s3_bucket.origin.bucket
}

# Security Headers

output "security_headers_enabled" {
  value = var.lambda_security_headers_enabled
}

# Basic Auth

output "basic_auth_enabled" {
  value = var.lambda_basic_auth_enabled
}

output "basic_auth_username" {
  value = var.lambda_basic_auth_username
}

output "basic_auth_password" {
  value = var.lambda_basic_auth_password
}

