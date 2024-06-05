variable "lambda_function_tags" {
  description = "Tags used on the Lambda function"
  type = map(string)
  default = { }
}

variable "api_gateway_api_tags" {
  description = "Tags used on the API Gateway API"
  type = map(string)
  default = { }
}

variable "app_key_dev" {
  description = "Application key when in development environment"
  type = string
}

variable "app_key_prod" {
  description = "Application key when in production environment"
  type = string
}

variable "cloudwatch_event_rule_scheduled_worker_enabled" {
  description = "The value determines if to enable a CW Event rule for the scheduled worker"
  type = bool
  default = true
}

variable "cloudwatch_event_rule_scheduled_worker_tags" {
  description = "Tags of the CW Event scheduled worker rule"
  type = map(string)
  default = { }
}

variable "iam_role_tags" {
  description = "Tags used on the IAM role"
  type = map(string)
  default = { }
}

variable "s3_bucket_storage_tags" {
  description = "Tags used on the S3 bucket for application storage"
  type = map(string)
  default = { }
}

variable "sns_jira_workload_notifications_users" {
  description = "List of users to notify for Jira workload"
  type        = list(map(string))
  default = [ ]
}

variable "sns_topic_subscription_alarms_target_email" {
  description = "Email address of the recipient of CloudWatch alarm notification"
  type = string
  default = ""
}

variable "sns_topic_subscription_jira_workload_manager_email" {
  description = "Email address of the manager that should receive of Jira workload notification"
  type = string
  default = ""
}

variable "sqs_dead_letter_queue_tags" {
  description = "Tags of the SQS Queue"
  type = map(string)
  default = { }
}

variable "sqs_queue_tags" {
  description = "Tags of the SQS Queue"
  type = map(string)
  default = { }
}

variable "sqs_queue_max_receive_count" {
  description = "The value determines the number of attempts before a message is moved to the SQS Dead Letter queue"
  type = number
  default = 3
}

variable "ssm_parameter_store_variables_tags" {
  description = "Tags used on the SSM Parameter Store variables"
  type = map(string)
  default = { }
}