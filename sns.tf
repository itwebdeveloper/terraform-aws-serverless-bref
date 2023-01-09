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