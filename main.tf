data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.deployment.id
  key    = aws_s3_object.artifact.key
}

resource "aws_lambda_function" "web" {
  function_name                  = "${var.application_slug}-${var.app_env}-web"
  handler                        = var.lambda_function_web_handler
  layers                         = [
    var.lambda_layer_php_fpm_arn,
  ]
  memory_size                    = var.lambda_function_web_memory_size
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = "provided.al2"
  source_code_hash               = data.aws_s3_object.artifact.metadata["Filesha256"]
  tags                           = var.lambda_function_tags
  timeout                        = var.lambda_function_web_timeout
  s3_bucket                      = aws_s3_bucket.deployment.id
  s3_key                         = aws_s3_object.artifact.key

  environment {
    variables = {
      "APP_DEBUG"         = var.app_env == "dev" ? "true" : "false"
      "APP_ENV"           = var.app_env == "dev" ? "local" : "production"
      "APP_KEY"           = var.app_env == "dev" ? var.app_key_dev : aws_ssm_parameter.app_key_prod.value
      "AWS_BUCKET"        = aws_s3_bucket.storage.id
      "FILESYSTEM_DRIVER" = "s3"
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.web.execution_arn}/*"
}

resource "aws_lambda_function" "artisan" {
  function_name                  = "${var.application_slug}-${var.app_env}-artisan"
  handler                        = var.lambda_function_artisan_handler
  layers                         = [
    var.lambda_layer_php_arn,
    var.lambda_layer_console_arn,
  ]
  memory_size                    = var.lambda_function_artisan_memory_size
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = "provided.al2"
  source_code_hash               = data.aws_s3_object.artifact.metadata["Filesha256"]
  tags                           = var.lambda_function_tags
  timeout                        = var.lambda_function_artisan_timeout
  s3_bucket                      = aws_s3_bucket.deployment.id
  s3_key                         = aws_s3_object.artifact.key

  environment {
    variables = {
      "APP_DEBUG"         = var.app_env == "dev" ? "true" : "false"
      "APP_ENV"           = var.app_env == "dev" ? "local" : "production"
      "APP_KEY"           = var.app_env == "dev" ? var.app_key_dev : aws_ssm_parameter.app_key_prod.value
      "AWS_BUCKET"        = aws_s3_bucket.storage.id
      "FILESYSTEM_DRIVER" = "s3"
    }
  }
}