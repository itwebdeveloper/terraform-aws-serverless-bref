locals {
  # Extract initials from application_name for DynamoDB table prefix
  application_initials = join("", [
    for word in split(" ", var.application_name) : 
    lower(substr(word, 0, 1))
  ])
  
  # Use provided dynamodb_table_prefix or default to application initials
  dynamodb_table_prefix = var.dynamodb_table_prefix != null ? var.dynamodb_table_prefix : "${local.application_initials}_"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.deployment.id
  key    = aws_s3_object.artifact.key
}

resource "aws_lambda_function" "web" {
  function_name                  = "${var.application_slug}-${var.app_env}-web"
  handler                        = var.lambda_function_web_handler
  layers                         = var.lambda_function_web_layers
  memory_size                    = var.lambda_function_web_memory_size
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = var.lambda_function_web_runtime
  source_code_hash               = data.aws_s3_object.artifact.metadata["Filesha256"]
  tags                           = var.lambda_function_tags
  timeout                        = var.lambda_function_web_timeout
  s3_bucket                      = aws_s3_bucket.deployment.id
  s3_key                         = aws_s3_object.artifact.key

  environment {
    variables = merge(
      {
        "APP_DEBUG"         = var.app_env == "dev" ? "true" : "false"
        "APP_ENV"           = var.app_env == "dev" ? "local" : "production"
        "APP_KEY"           = var.app_env == "dev" ? var.app_key_dev : (var.ssm_parameter_app_key_prod_create ? aws_ssm_parameter.app_key_prod[0].value : var.app_key_prod)
        "AWS_BUCKET"        = var.s3_bucket_storage_create ? aws_s3_bucket.storage[0].id : ""
        "FILESYSTEM_DRIVER" = var.s3_bucket_storage_create ? "s3" : "local"
      },
      var.lambda_function_web_environment_variables
    )
  }
}

resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.web.execution_arn}/*"
}

resource "aws_lambda_function" "artisan" {
  count                          = var.lambda_function_artisan_create ? 1 : 0
  function_name                  = "${var.application_slug}-${var.app_env}-artisan"
  handler                        = var.lambda_function_artisan_handler
  layers                         = var.lambda_function_artisan_layers
  memory_size                    = var.lambda_function_artisan_memory_size
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = var.lambda_function_artisan_runtime
  source_code_hash               = data.aws_s3_object.artifact.metadata["Filesha256"]
  tags                           = var.lambda_function_tags
  timeout                        = var.lambda_function_artisan_timeout
  s3_bucket                      = aws_s3_bucket.deployment.id
  s3_key                         = aws_s3_object.artifact.key

  environment {
    variables = {
      "APP_DEBUG"         = var.app_env == "dev" ? "true" : "false"
      "APP_ENV"           = var.app_env == "dev" ? "local" : "production"
      "APP_KEY"           = var.app_env == "dev" ? var.app_key_dev : (var.ssm_parameter_app_key_prod_create ? aws_ssm_parameter.app_key_prod[0].value : var.app_key_prod)
      "AWS_BUCKET"        = var.s3_bucket_storage_create ? aws_s3_bucket.storage[0].id : ""
      "FILESYSTEM_DRIVER" = var.s3_bucket_storage_create ? "s3" : "local"
    }
  }
}

resource "aws_lambda_function" "worker" {
  count                          = var.sqs_queue_create && var.lambda_function_worker_create ? 1 : 0
  function_name                  = "${var.application_slug}-${var.app_env}-worker"
  handler                        = var.lambda_function_worker_handler
  layers                         = var.lambda_function_worker_layers
  memory_size                    = var.lambda_function_worker_memory_size
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = var.lambda_function_worker_runtime
  source_code_hash               = data.aws_s3_object.artifact.metadata["Filesha256"]
  tags                           = var.lambda_function_tags
  timeout                        = var.lambda_function_worker_timeout
  s3_bucket                      = aws_s3_bucket.deployment.id
  s3_key                         = aws_s3_object.artifact.key

  environment {
    variables = {
      "APP_DEBUG"         = var.app_env == "dev" ? "true" : "false"
      "APP_ENV"           = var.app_env == "dev" ? "local" : "production"
      "APP_KEY"           = var.app_env == "dev" ? var.app_key_dev : (var.ssm_parameter_app_key_prod_create ? aws_ssm_parameter.app_key_prod[0].value : var.app_key_prod)
      "AWS_BUCKET"        = var.s3_bucket_storage_create ? aws_s3_bucket.storage[0].id : ""
      "FILESYSTEM_DRIVER" = var.s3_bucket_storage_create ? "s3" : "local"
      "SQS_QUEUE"         = aws_sqs_queue.application_queue[0].url
    }
  }
}

resource "aws_lambda_event_source_mapping" "worker_sqs_trigger" {
  count = var.sqs_queue_create && var.lambda_function_worker_create ? 1 : 0
  event_source_arn = aws_sqs_queue.application_queue[0].arn
  function_name    = aws_lambda_function.worker[0].arn
}