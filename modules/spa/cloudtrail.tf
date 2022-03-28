resource "aws_cloudtrail" "default_trail" {
  depends_on                    = [aws_s3_bucket_policy.cloudtrail_logs]
  name                          = "${module.label.id}-default-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = var.cloudtrail_s3_prefix
  enable_logging                = var.cloudtrail_enabled
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.default_trail_cloudwatch_logs.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.default_trail.arn
}

# ----------------------
# Config cloudwatch log group
# ----------------------

resource "aws_cloudwatch_log_group" "default_trail_cloudwatch_logs" {
  name = "${module.label.id}-default-trail-logs"
}

# IAM role for cloudwatch logs
resource "aws_iam_role" "default_trail" {
  name = "${module.label.id}-default-trail-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "${module.label.id}-default-trail-logs-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:*"]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.default_trail_cloudwatch_logs.arn}:*"
        },
      ]
    })
  }

}

# ----------------------
# Config Cloudwatch Alarms
# ----------------------


# Changes to IAM resources
resource "aws_cloudwatch_log_metric_filter" "iam_change" {
  name           = "${module.label.id}-iam-changes"
  pattern        = "{$.eventSource = iam.* && $.eventName != Get* && $.eventName != List*}"
  log_group_name = aws_cloudwatch_log_group.default_trail_cloudwatch_logs.name

  metric_transformation {
    name      = "IamChanges"
    namespace = module.label.id
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_change" {
  alarm_name          = "${module.label.id}-iam-changes-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "IamChanges"
  namespace           = module.label.id
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "IAM Resources have been changed"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
