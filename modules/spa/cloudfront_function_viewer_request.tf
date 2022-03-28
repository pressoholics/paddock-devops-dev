locals {
  basic_auth_vars = {
    basicAuthEnabled = jsonencode(var.lambda_basic_auth_enabled)
    authUser         = var.lambda_basic_auth_username
    authPass         = var.lambda_basic_auth_password
    authToken        = var.lambda_basic_auth_token
    ipWhitelist      = jsonencode(var.lambda_basic_auth_ip_whitelist)
  }
  default_viewer_request_vars = {
    unsupported = file("${path.module}/templates/chunks/cf_unsupported_http_redirect.js"),
    basicAuth   = templatefile("${path.module}/templates/chunks/cf_basic_auth.tpl", local.basic_auth_vars)
  }
}

resource "aws_cloudfront_function" "default_viewer_request" {
  name    = "${module.label.id}-default-viewer-request"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = templatefile("${path.module}/templates/behaviors/default/cf_viewer_request.tpl", local.default_viewer_request_vars)
}

