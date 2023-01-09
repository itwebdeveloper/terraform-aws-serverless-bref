resource "aws_sqs_queue" "application_queue" {
  count                             = var.sqs_queue_create ? 1 : 0
  name                              = "${var.application_slug}-${var.app_env}-sqs-queue"
  redrive_policy                    = var.sqs_dead_letter_queue_create ? jsonencode(
    {
      deadLetterTargetArn = aws_sqs_queue.application_dead_letter_queue[0].arn
      maxReceiveCount     = 3
    }
  ) : null
  sqs_managed_sse_enabled           = true
  tags                              = var.sqs_queue_tags
}

resource "aws_sqs_queue" "application_dead_letter_queue" {
  count                             = var.sqs_dead_letter_queue_create ? 1 : 0
  name                              = "${var.application_slug}-${var.app_env}-sqs-dead-letter-queue"
  sqs_managed_sse_enabled           = true
  tags                              = var.sqs_dead_letter_queue_tags
}