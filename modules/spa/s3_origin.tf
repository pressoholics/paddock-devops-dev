# Origin S3 bucket static website 
resource "aws_s3_bucket" "origin" {
  bucket        = "${module.label.id}-origin"
  acl           = "private"
  force_destroy = var.origin_s3_force_destroy
  depends_on    = [aws_s3_bucket.logs]

  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = var.origin_s3_log_prefix
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "404/index.html"
  }
}

# Origin S3 bucket static website bucket policy
resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "ORIGINBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "Allow GET requests from authorized origins",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.origin.arn}/*",
      "Condition": {
        "StringLike": {
          "aws:Referer": ["${random_id.referer.b64_std}"]
        }
      }
    }
  ]
}
POLICY
}

# Random value for S3 origin bucket policy Referer condition
resource "random_id" "referer" {
  byte_length = 24
}
