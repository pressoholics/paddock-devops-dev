# CloudWatch alarm for CloudFront 4xx 
resource "aws_cloudwatch_metric_alarm" "cf_4xx_errors" {
  alarm_name                = "${module.label.id}-cf-4xx-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "5"
  alarm_description         = "CloudFront 4xx error rate has exceeded threshold"
  alarm_actions             = [module.sns_topic_cf_alarms.arn]
  ok_actions                = [module.sns_topic_cf_alarms.arn]
  insufficient_data_actions = []

  metric_query {
    id          = "cfe4xx"
    return_data = true

    metric {
      metric_name = "4xxErrorRate"
      namespace   = "AWS/CloudFront"
      period      = "120"
      stat        = "Average"
      unit        = "Percent"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.default.id
        Region         = "Global"
      }
    }
  }
}

# CloudWatch alarm for CloudFront 5xx 
resource "aws_cloudwatch_metric_alarm" "cf_5xx_errors" {
  alarm_name                = "${module.label.id}-cf-5xx-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "5"
  alarm_description         = "CloudFront 5xx error rate has exceeded threshold"
  alarm_actions             = [module.sns_topic_cf_alarms.arn]
  ok_actions                = [module.sns_topic_cf_alarms.arn]
  insufficient_data_actions = []

  metric_query {
    id          = "cfe5xx"
    return_data = true

    metric {
      metric_name = "5xxErrorRate"
      namespace   = "AWS/CloudFront"
      period      = "120"
      stat        = "Average"
      unit        = "Percent"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.default.id
        Region         = "Global"
      }
    }
  }
}

# CloudWatch alarm for unusal CloudFront request sum
resource "aws_cloudwatch_metric_alarm" "cf_request_high_anomaly" {
  alarm_name                = "${module.label.id}-cf-request-high-anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  threshold_metric_id       = "e1"
  alarm_description         = "CloudFront request sum high threshold anomaly"
  alarm_actions             = [module.sns_topic_cf_alarms.arn]
  ok_actions                = [module.sns_topic_cf_alarms.arn]
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Request sum (Expected)"
    return_data = true
  }

  metric_query {
    id          = "m1"
    return_data = true

    metric {
      metric_name = "Requests"
      namespace   = "AWS/CloudFront"
      period      = "120"
      stat        = "Sum"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.default.id
        Region         = "Global"
      }
    }
  }
}

# CloudWatch alarm for unusal CloudFront bytes downloaded
resource "aws_cloudwatch_metric_alarm" "cf_bytes_down_anomaly" {
  alarm_name                = "${module.label.id}-cf-bytes-down-anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  threshold_metric_id       = "e1"
  alarm_description         = "CloudFront bytes downloaded high threshold anomaly"
  alarm_actions             = [module.sns_topic_cf_alarms.arn]
  ok_actions                = [module.sns_topic_cf_alarms.arn]
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Bytes down sum (Expected)"
    return_data = true
  }

  metric_query {
    id          = "m1"
    return_data = true

    metric {
      metric_name = "BytesDownloaded"
      namespace   = "AWS/CloudFront"
      period      = "120"
      stat        = "Sum"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.default.id
        Region         = "Global"
      }
    }
  }
}
