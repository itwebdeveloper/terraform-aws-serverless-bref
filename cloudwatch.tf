resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/lambda/${var.application_slug}-${var.app_env}-web"
  retention_in_days = var.cloudwatch_log_group_web_retention
  tags              = var.cloudwatch_log_group_web_tags
}

resource "aws_cloudwatch_log_group" "artisan" {
  name              = "/aws/lambda/${var.application_slug}-${var.app_env}-artisan"
  retention_in_days = var.cloudwatch_log_group_artisan_retention
  tags              = var.cloudwatch_log_group_artisan_tags
}