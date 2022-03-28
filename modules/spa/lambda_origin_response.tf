locals {
  lambda_security_headers_vars = {
    defaultSrc    = jsonencode(var.lambda_security_headers_default_source)
    imgSrc        = jsonencode(var.lambda_security_headers_image_source)
    styleSrc      = jsonencode(var.lambda_security_headers_style_source)
    fontSrc       = jsonencode(var.lambda_security_headers_font_source)
    mediaSrc      = jsonencode(var.lambda_security_headers_media_source)
    connectSrc    = jsonencode(var.lambda_security_headers_connect_source)
    scriptSrc     = jsonencode(var.lambda_security_headers_script_source)
    cspReportOnly = jsonencode(var.lambda_security_headers_csp_report_only)
    allowXFrame   = jsonencode(var.lambda_security_headers_allow_x_frame)
  }
  default_origin_response_vars = {
    securityHeaders = templatefile("${path.module}/templates/chunks/lambda_security_headers.tpl", local.lambda_security_headers_vars)
  }
}


module "lambda_default_origin_response" {
  source = "../lambda_at_edge"
  providers = {
    aws  = aws.us-east-1
  }
  name = "${module.label.id}-default-origin-response"
  content = templatefile("${path.module}/templates/behaviors/default/lambda_origin_response.tpl", local.default_origin_response_vars)
}
