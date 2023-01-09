provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

module "aws_resource_simple_app" {
  source  = "itwebdeveloper/serverless-bref/aws"
  version = "0.1.1"

  api_gateway_api_tags                            = var.api_gateway_api_tags
  api_gateway_route_throttling_burst_limit        = 5
  api_gateway_route_throttling_rate_limit         = 10
  app_key_dev                                     = var.app_key_dev
  app_key_prod                                    = var.app_key_prod
  application_name                                = "My simple app"
  application_slug                                = "my-simple-app"
  artifact_file_name                              = "simple-app.zip"
  artifact_folder_path                            = "artifact/"
  cloudwatch_event_rule_scheduled_worker_enabled  = var.cloudwatch_event_rule_scheduled_worker_enabled
  cloudwatch_event_rule_scheduled_worker_tags     = var.lambda_function_tags
  cloudwatch_log_group_artisan_retention          = 7
  cloudwatch_log_group_web_retention              = 7
  iam_role_tags                                   = var.iam_role_tags
  lambda_function_artisan_memory_size             = 1024
  lambda_function_artisan_timeout                 = 120
  lambda_function_web_memory_size                 = 1024
  lambda_function_web_timeout                     = 28
  lambda_function_worker_create                   = true
  lambda_function_worker_memory_size              = 1024
  lambda_function_worker_timeout                  = 30
  lambda_function_tags                            = var.lambda_function_tags
  lambda_layer_console_arn                        = "arn:aws:lambda:eu-west-1:209497400698:layer:console:62"
  lambda_layer_php_arn                            = "arn:aws:lambda:eu-west-1:209497400698:layer:php-74:48"
  lambda_layer_php_fpm_arn                        = "arn:aws:lambda:eu-west-1:209497400698:layer:php-74-fpm:48"
  s3_bucket_storage_tags                          = var.s3_bucket_storage_tags
  sns_topic_subscription_alarms_target_email      = var.sns_topic_subscription_alarms_target_email
  sqs_dead_letter_queue_tags                      = var.sqs_dead_letter_queue_tags
  sqs_queue_tags                                  = var.sqs_queue_tags
  ssm_parameter_store_variables_tags              = var.ssm_parameter_store_variables_tags
}