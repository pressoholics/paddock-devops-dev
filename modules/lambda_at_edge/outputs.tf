output "function_arn" {
  value = aws_lambda_function.lambda_at_edge.qualified_arn
}

output "function_name" {
  value = var.name
}
