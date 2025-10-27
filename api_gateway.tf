resource "aws_apigatewayv2_api" "web" {
  name                         = "${var.app_env}-${var.application_slug}"
  protocol_type                = "HTTP"
  tags                         = var.api_gateway_api_tags

  # Add CORS configuration when specific methods are defined (not $default)
  dynamic "cors_configuration" {
    for_each = var.api_gateway_allowed_methods != ["$default"] ? [1] : []
    content {
      allow_credentials = false
      allow_headers = [
        "Content-Type",
        "X-Amz-Date",
        "Authorization",
        "X-Api-Key",
        "X-Amz-Security-Token"
      ]
      allow_methods = var.api_gateway_allowed_methods
      allow_origins = ["*"]
      expose_headers = []
      max_age = 300
    }
  }
}

resource "aws_apigatewayv2_integration" "web" {
  api_id                 = aws_apigatewayv2_api.web.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.web.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "web" {
  for_each = toset(var.api_gateway_allowed_methods)
  api_id   = aws_apigatewayv2_api.web.id
  route_key = each.value == "$default" ? "$default" : "${each.value} /"
  target   = "integrations/${aws_apigatewayv2_integration.web.id}"
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


