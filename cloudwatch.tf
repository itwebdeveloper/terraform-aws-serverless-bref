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

resource "aws_cloudwatch_event_rule" "scheduled_worker" {
  count               = var.cloudwatch_event_scheduled_worker_create ? 1 : 0
  description         = "Scheduled rule for ${var.application_name} Worker"
  is_enabled          = var.cloudwatch_event_rule_scheduled_worker_enabled
  name                = "${var.application_slug}-${var.app_env}-scheduled-rule"
  schedule_expression = var.cloudwatch_event_rule_scheduled_worker_schedule
  tags                = var.cloudwatch_event_rule_scheduled_worker_tags
}

resource "aws_cloudwatch_event_target" "scheduled_worker" {
  count          = var.cloudwatch_event_scheduled_worker_create ? 1 : 0
  arn            = aws_lambda_function.artisan.arn
  input          = "\"queue:work --stop-when-empty\""
  rule           = aws_cloudwatch_event_rule.scheduled_worker[0].name
}

resource "aws_cloudwatch_event_rule" "notify_jira_workload" {
  count               = var.cloudwatch_event_scheduled_worker_create ? 1 : 0
  description         = "Scheduled rule for ${var.application_name} notify-jira-workload"
  is_enabled          = true
  name                = "${var.application_slug}-${var.app_env}-scheduled-rule-notify-jira-workload"
  schedule_expression = "cron(*/15 7-18 ? * MON-FRI *)"
  tags                = var.cloudwatch_event_rule_scheduled_worker_tags

  lifecycle {
    ignore_changes = [
      is_enabled
    ]
  }
}

resource "aws_cloudwatch_event_target" "notify_jira_workload" {
  count          = var.cloudwatch_event_scheduled_worker_create ? 1 : 0
  arn            = aws_lambda_function.artisan.arn
  input          = "\"jira:notify-jira-workload\""
  rule           = aws_cloudwatch_event_rule.notify_jira_workload[0].name
}

resource "aws_cloudwatch_metric_alarm" "dead_letter_queue_too_many_messages" {
  count = var.cloudwatch_dead_letter_queue_too_many_messages_alarm_create && var.sqs_dead_letter_queue_create ? 1 : 0
  alarm_actions             = var.sns_topic_alarms_create ? [
    aws_sns_topic.alarms[0].arn,
  ] : null
  alarm_description         = "CloudWatch alarm triggered when there are too many messages in the SQS Dead Letter queue."
  alarm_name                = "${var.application_slug}-${var.app_env}-sqs-dead-letter-queue-too-many-messages"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "NumberOfMessagesReceived"
  namespace                 = "AWS/SQS"
  period                    = 300
  statistic                 = "Average"
  dimensions                = {
    "QueueName" = aws_sqs_queue.application_dead_letter_queue[0].name
  }
}

