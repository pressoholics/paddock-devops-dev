
# Create lambda zip
data "archive_file" "lambda_at_edge_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${var.name}.zip"
  source {
    filename = "index.js"
    content  = var.content
  }
}

# Lambda function
resource "aws_lambda_function" "lambda_at_edge" {
  provider         = aws
  function_name    = var.name
  role             = aws_iam_role.lambda_at_edge.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  filename         = data.archive_file.lambda_at_edge_zip.output_path
  source_code_hash = data.archive_file.lambda_at_edge_zip.output_base64sha256
  publish          = true
}
