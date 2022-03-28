# S3 bucket for logging
resource "aws_s3_bucket" "logs" {
  bucket        = "${module.label.id}-logs"
  acl           = "log-delivery-write"
  force_destroy = var.logs_s3_force_destroy
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${module.label.id}-cloud-trail-logs"
  force_destroy = var.logs_s3_force_destroy
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    Id        = "CLOUDTRAILPOLICY"
    "Statement" = [
      {
        "Sid"       = "AWSCloudTrailAclCheck20150319",
        "Effect"    = "Allow",
        "Principal" = { "Service" = "cloudtrail.amazonaws.com" },
        "Action"    = "s3:GetBucketAcl",
        "Resource"  = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        "Sid"       = "AWSCloudTrailWrite20150319",
        "Effect"    = "Allow",
        "Principal" = { "Service" = "cloudtrail.amazonaws.com" },
        "Action"    = "s3:PutObject",
        "Resource"  = "${aws_s3_bucket.cloudtrail_logs.arn}/${var.cloudtrail_s3_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition" = { "StringEquals" = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

resource "aws_s3_bucket" "trusted_advisor" {
  bucket = "${module.label.id}-trusted-advisor"
  acl    = "private"
}
