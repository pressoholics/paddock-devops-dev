### General Settings ###
region = "us-east-1"
# Your role_arn is the terraformRole you create via CLI
role_arn = "AWS_IAM_ROLE_ARN_VALUE"
# Change to your project name
name        = "devops-boilerplate"
namespace   = "jam3"
environment = "stage"

### Custom Domain ###
# Use the following variables if you wish to use a custom domain.
# Note the following:
# - ACM certificate and Route53 zone must be created in the project account
# - ACM certificate must be present in the us-east-1 region
# - ACM certificate must be valid for the custom domain
# - Route53 zone must match the custom domain 
# - Set route53_enabled to false to prevent Terraform from creating Route53 records
#
#cloudfront_domain              = "CUSTOM_DOMAIN_NAME_VALUE"
#cloudfront_domain_aliases      = ["CUSTOM_DOMAIN_NAME_VALUE"]
#cloudfront_acm_certificate_arn = "CUSTOM_DOMAIN_CERTIFICATE_ARN_VALUE"
#route53_zone_id                = "CUSTOM_DOMAIN_ROUTE53_ZONE_ID_VALUE"
#route53_enabled                = false

### CloudFront ###
cloudfront_price_class         = "PriceClass_All"
cloudfront_wait_for_deployment = false

### Notification ###
alarm_email_address = "ALARM_NOTIFICATION_EMAIL_ADDRESS_VALUE"

### Origin ###
origin_s3_force_destroy = true

### Logging ###
logs_s3_force_destroy = true

### Lambda ###
lambda_basic_auth_enabled      = false
lambda_basic_auth_username     = ""
lambda_basic_auth_password     = ""
lambda_basic_auth_token        = ""
lambda_basic_auth_ip_whitelist = []

### Lambda - Security Headers ###
lambda_security_headers_enabled         = true
lambda_security_headers_csp_report_only = true
lambda_security_headers_default_source  = []
lambda_security_headers_image_source    = []
lambda_security_headers_style_source    = []
lambda_security_headers_font_source     = []
lambda_security_headers_media_source    = []
lambda_security_headers_connect_source  = []
lambda_security_headers_script_source   = []
lambda_security_headers_allow_x_frame   = true

### Cloud Trail ###
cloudtrail_enabled = true
