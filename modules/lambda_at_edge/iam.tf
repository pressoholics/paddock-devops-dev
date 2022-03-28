locals {
  iam_policy_arn = flatten([
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  var.policy_arns])
}

resource "aws_iam_role" "lambda_at_edge" {
  name               = "${var.name}-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": {
            "Service": [
               "lambda.amazonaws.com",
               "edgelambda.amazonaws.com"
            ]
         },
         "Action": "sts:AssumeRole"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_at_edge" {
  role       = aws_iam_role.lambda_at_edge.name
  count      = length(local.iam_policy_arn)
  policy_arn = local.iam_policy_arn[count.index]
}
