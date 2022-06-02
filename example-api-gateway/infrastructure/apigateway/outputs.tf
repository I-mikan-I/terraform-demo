output "execution-arn" {
  value = aws_apigatewayv2_api.gateway.execution_arn
}

output "invoke-url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}