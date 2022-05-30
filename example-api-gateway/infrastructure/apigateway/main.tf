terraform {
  required_providers{
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16.0"
    }
  }
}

resource "aws_apigatewayv2_api" "gateway" {
  name          = "tf_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.gateway.id

  name        = "default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "integration" {
  count = length(var.integrations)
  integration_uri = var.integrations[count.index].arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  api_id = aws_apigatewayv2_api.gateway.id
}

resource "aws_apigatewayv2_route" "routes" {
  count = length(var.integrations)
  route_key = "GET ${var.integrations[count.index].route}"
  target = "integrations/${aws_apigatewayv2_integration.integration[count.index].id}"
  api_id = aws_apigatewayv2_api.gateway.id
}