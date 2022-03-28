# SNS topic with email subscription for CloudFront alarms
module "sns_topic_cf_alarms" {
  source        = "git::https://github.com/deanwilson/tf_sns_email.git"
  display_name  = "AWS Infrastructure Alarm Notification"
  email_address = var.alarm_email_address
  stack_name    = "${module.label.id}-cf-alarms-sns"
}

# SNS Cloudtrail alerts
resource "aws_sns_topic" "security_alerts" {
  name         = "${module.label.id}-cloudtrail-alerts-topic"
  display_name = "Cloudtrail Security Alerts"
}

resource "aws_sns_topic_subscription" "security_alerts_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email_address
}
