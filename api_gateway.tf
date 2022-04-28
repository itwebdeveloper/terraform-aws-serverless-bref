resource "aws_apigatewayv2_api" "web" {
  name                         = "${var.app_env}-${var.application_slug}"
  protocol_type                = "HTTP"
  tags                         = var.api_gateway_api_tags
}

resource "aws_apigatewayv2_integration" "web" {
  api_id                 = aws_apigatewayv2_api.web.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.web.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "web" {
  api_id               = aws_apigatewayv2_api.web.id
  route_key            = "$default"
  target               = "integrations/${aws_apigatewayv2_integration.web.id}"
}

resource "aws_apigatewayv2_stage" "web" {
  api_id          = aws_apigatewayv2_api.web.id
  auto_deploy     = true
  name            = var.api_gateway_stage_name
  tags            = var.api_gateway_stage_tags

  default_route_settings {
    throttling_burst_limit   = var.api_gateway_route_throttling_burst_limit
    throttling_rate_limit    = var.api_gateway_route_throttling_rate_limit
  }
}