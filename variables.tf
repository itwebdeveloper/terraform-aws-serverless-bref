variable "api_gateway_api_tags" {
  description = "Tags used on the API Gateway API"
  type = map(string)
  default = { }
}

variable "api_gateway_route_throttling_burst_limit" {
  description = "Throttling burst limit for the API Gateway route"
  type = number
}

variable "api_gateway_route_throttling_rate_limit" {
  description = "Throttling rate limit for the API Gateway route"
  type = number
}

variable "api_gateway_stage_name" {
  description = "Name of the API Gateway default stage"
  type = string
  default = "$default"
}

variable "api_gateway_stage_tags" {
  description = "Tags of the API Gateway default stage"
  type = map(string)
  default = { }
}

variable "app_env" {
  description = "Application environment"
  type = string
  default = "dev"

  validation {
    condition = anytrue([
      var.app_env == "dev",
      var.app_env == "prod",
    ])
    error_message = "Must be a valid env, can be dev or prod."
  }
}

variable "app_key_dev" {
  description = "Application key when in development environment"
  type = string
}

variable "app_key_prod" {
  description = "Application key when in production environment"
  type = string
}

variable "application_name" {
  description = "Application name"
  type = string
}

variable "application_slug" {
  description = "Dash-separated-lowercase application name"
  type = string
}

variable "artifact_file_name" {
  description = "Name of the artifact (including extension)"
  type = string
}

variable "artifact_folder_path" {
  description = "Path of the folder containing the artifact file, relative to the root of the project"
  type = string
}

variable "cloudwatch_log_group_artisan_retention" {
  description = "Retention in days of the logs in the Artisan CW Log Group"
  type = number
}

variable "cloudwatch_log_group_artisan_tags" {
  description = "Tags of the Artisan CW Log Group"
  type = map(string)
  default = { }
}

variable "cloudwatch_log_group_web_retention" {
  description = "Retention in days of the logs in the Web CW Log Group"
  type = number
}

variable "cloudwatch_log_group_web_tags" {
  description = "Tags of the Web CW Log Group"
  type = map(string)
  default = { }
}

variable "iam_role_tags" {
  description = "Tags used on the IAM role"
  type = map(string)
  default = { }
}

variable "lambda_function_tags" {
  description = "Tags used on the Lambda function"
  type = map(string)
  default = { }
}

variable "lambda_function_artisan_handler" {
  description = "Handler of the Artisan Lambda function"
  type = string
  default = "artisan"
}

variable "lambda_function_artisan_memory_size" {
  description = "Size of the Artisan Lambda function"
  type = number
}

variable "lambda_function_artisan_timeout" {
  description = "Timeout value of the Artisan Lambda function"
  type = number
}

variable "lambda_function_web_handler" {
  description = "Handler of the Web Lambda function"
  type = string
  default = "public/index.php"
}

variable "lambda_function_web_memory_size" {
  description = "Size of the web Lambda function"
  type = number
}

variable "lambda_function_web_timeout" {
  description = "Timeout value of the web Lambda function"
  type = number
}

variable "lambda_layer_console_arn" {
  description = "ARN to the Laravel Console Lambda layer"
  type = string
}

variable "lambda_layer_php_arn" {
  description = "ARN to the PHP Lambda layer"
  type = string
}

variable "lambda_layer_php_fpm_arn" {
  description = "ARN to the PHP-FPM Lambda layer"
  type = string
}

variable "s3_bucket_storage_tags" {
  description = "Tags used on the S3 bucket for application storage"
  type = map(string)
  default = { }
}

variable "ssm_parameter_store_variables_tags" {
  description = "Tags used on the SSM Parameter Store variables"
  type = map(string)
  default = { }
}