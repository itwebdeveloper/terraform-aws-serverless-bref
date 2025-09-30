output "api_endpoint" {
  description = "Exposed URL"
  value       = var.cloudfront_create ? aws_cloudfront_distribution.main[0].domain_name : aws_apigatewayv2_api.web.api_endpoint
}