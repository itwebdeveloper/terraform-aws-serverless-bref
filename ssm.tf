resource "aws_ssm_parameter" "app_key_prod" {
  description = "${var.application_name} - Production Environment - Laravel Framework parameter - Key used for encryption"
  name        = "/${var.application_slug}-prod/APP_KEY"
  tags        = var.ssm_parameter_store_variables_tags
  type        = "String"
  value       = var.app_key_prod

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}