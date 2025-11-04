resource "aws_iam_role" "lambda_role" {
  assume_role_policy    = jsonencode(
    {
      Statement = [
        {
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version   = "2012-10-17"
    }
  )
  name                  = "${var.application_slug}-${var.app_env}-${data.aws_region.current.name}-lambdaRole"
  tags                  = var.iam_role_tags

  inline_policy {
    name   = "${var.application_slug}-${var.app_env}-lambda"
    policy = jsonencode(
      {
        Statement = concat(
          [
            {
              Action   = [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
              ]
              Effect   = "Allow"
              Resource = [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.application_slug}-${var.app_env}*:*",
              ]
            },
            {
              Action   = [
                "logs:PutLogEvents",
              ]
              Effect   = "Allow"
              Resource = [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.application_slug}-${var.app_env}*:*:*",
              ]
            },
            {
              Action   = [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
              ]
              Effect   = "Allow"
              Resource = [
                "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${local.dynamodb_table_prefix}*",
              ]
            },
          ],
          var.sqs_queue_create ? [
            {
              Action   = [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes",
                "sqs:SendMessage",
              ]
              Effect   = "Allow"
              Resource = [
                "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.application_slug}-${var.app_env}-sqs-queue",
              ]
            }
          ] : [],
          var.s3_bucket_storage_create ? [
            {
              Action   = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
              ]
              Effect   = "Allow"
              Resource = [
                aws_s3_bucket.storage[0].arn,
                "${aws_s3_bucket.storage[0].arn}/*",
              ]
            }
          ] : [],
          length(var.sns_jira_workload_notifications_users) > 0 ? [
            {
              Action   = [
                "sns:Publish",
              ]
              Effect   = "Allow"
              Resource = [
                for user in var.sns_jira_workload_notifications_users : 
                "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.application_slug}-${var.app_env}-notify-jira-workload-${user.slug}"
              ]
            }
          ] : [],
          var.additional_iam_policy_statements
        )
        Version   = "2012-10-17"
      }
    )
  }
}
