output "api_endpoint" {
  description = "Exposed URL"
  value       = aws_apigatewayv2_api.web.api_endpoint
}