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
        Statement = [
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
              "s3:*",
            ]
            Effect   = "Allow"
            Resource = [
              aws_s3_bucket.storage.arn,
              "${aws_s3_bucket.storage.arn}/*",
            ]
          },
        ]
        Version   = "2012-10-17"
      }
    )
  }
}
