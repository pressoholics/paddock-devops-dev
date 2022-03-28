# Provides consistent labels for resources
module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.21.0"
  name        = var.name
  namespace   = var.namespace
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

# # Trusted advisor
# module "trusted-advisor-refresh" {
#   source  = "trussworks/trusted-advisor-refresh/aws"
#   version = "~> 3.1.0"

#   environment       = var.environment
#   interval_minutes  = "5"
#   s3_bucket         = aws_s3_bucket.trusted_advisor.id
#   version_to_deploy = "1.0"
# }

# S3 redirects
#module "s3_redirect_example" {
#  source = "./modules/spa/s3_redirect"
#
#  host     = "example.ca"
#  domain   = "www.example.ca"
#  redirect = "https://example.ca"
#}
