resource "aws_sns_topic" "alarms" {
  count = var.sns_topic_alarms_create ? 1 : 0
  name  = "${var.application_slug}-${var.app_env}-cw-alarm-too-many-errors-topic"
}

resource "aws_sns_topic_subscription" "alarms_target" {
  count       = var.sns_topic_subscription_alarms_target_create && var.sns_topic_alarms_create ? 1 : 0
  endpoint    = var.sns_topic_subscription_alarms_target_email
  protocol    = "email"
  topic_arn   = aws_sns_topic.alarms[0].arn
}

resource "aws_sns_topic" "notify_jira_workload" {
  for_each    = { for u in var.sns_jira_workload_notifications_users : u.slug => u }
  name        = "${var.application_slug}-${var.app_env}-notify-jira-workload-${each.value.slug}"
}

resource "aws_sns_topic_subscription" "jira_workload" {
  for_each    = { for u in var.sns_jira_workload_notifications_users : u.slug => u }
  endpoint    = "${each.value.email}"
  protocol    = "email"
  topic_arn   = aws_sns_topic.notify_jira_workload[each.value.slug].arn
}

resource "aws_sns_topic_subscription" "jira_workload_manager" {
  for_each    = { for u in var.sns_jira_workload_notifications_users : u.slug => u }
  endpoint    = var.sns_topic_subscription_jira_workload_manager_email
  protocol    = "email"
  topic_arn   = aws_sns_topic.notify_jira_workload[each.key].arn
}