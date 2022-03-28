# IAM user for continous deployment service
resource "aws_iam_user" "cd" {
  name          = "${module.label.id}-deploy"
  force_destroy = true
  tags          = module.label.tags
}

# IAM policy for continuous deployment user
data "aws_iam_policy_document" "cd" {
  statement {
    sid     = "S3ALLOW"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.origin.arn,
      "${aws_s3_bucket.origin.arn}/*"
    ]
    effect = "Allow"
  }

  statement {
    sid       = "CFALLOW"
    actions   = ["cloudfront:*"]
    resources = [aws_cloudfront_distribution.default.arn]
    effect    = "Allow"
  }
}

# Assign inline IAM policy to continuous deployment user
resource "aws_iam_user_policy" "inline" {
  name   = "${module.label.id}-deploy-policy"
  user   = aws_iam_user.cd.name
  policy = data.aws_iam_policy_document.cd.json
}

# Access key for continuous deployment user
resource "aws_iam_access_key" "cd" {
  user = aws_iam_user.cd.name
}
