data "aws_canonical_user_id" "current" {}

resource "random_string" "storage_bucket_suffix" {
  length           = 12
  special          = false
  upper            = false
}

resource "random_string" "deployment_bucket_suffix" {
  length           = 12
  special          = false
  upper            = false
}

resource "aws_s3_bucket" "storage" {
  bucket                      = "${var.application_slug}-${var.app_env}-storage-${random_string.storage_bucket_suffix.result}"

  tags                        = var.s3_bucket_storage_tags

  lifecycle {
    ignore_changes = [
      bucket
    ]
  }
}

resource "aws_s3_bucket_acl" "storage" {
  bucket = aws_s3_bucket.storage.id

  access_control_policy {
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }

  lifecycle {
    ignore_changes = [
      access_control_policy[0].grant,
      access_control_policy[0].owner[0].id
    ]
  }
}

resource "aws_s3_bucket" "deployment" {
  bucket                      = "${var.application_slug}-${var.app_env}-deployment-${random_string.deployment_bucket_suffix.result}"
  tags                        = var.s3_bucket_storage_tags

  lifecycle {
    ignore_changes = [
      bucket,
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deployment" {
  bucket                = aws_s3_bucket.deployment.bucket
  expected_bucket_owner = data.aws_caller_identity.current.account_id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "deployment" {
  bucket                = aws_s3_bucket.deployment.id
  expected_bucket_owner = data.aws_caller_identity.current.account_id

  access_control_policy {
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_policy" "deployment" {
  bucket = aws_s3_bucket.deployment.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "s3:*"
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
          Effect    = "Deny"
          Principal = "*"
          Resource  = [
            "${aws_s3_bucket.deployment.arn}/*",
            "${aws_s3_bucket.deployment.arn}",
          ]
        },
      ]
      Version   = "2008-10-17"
    }
  )
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.deployment.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "null_resource" "artifact_sha" {
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${var.artifact_folder_path}${var.artifact_file_name} | openssl enc -base64 > ${var.artifact_folder_path}${var.artifact_file_name}.sha256"
  }
}

resource "aws_s3_object" "artifact" {
  bucket                 = aws_s3_bucket.deployment.id
  source                 = "${var.artifact_folder_path}${var.artifact_file_name}"
  content_type           = "application/zip"
  source_hash            = filemd5("${var.artifact_folder_path}${var.artifact_file_name}")
  key                    = "serverless/${var.application_slug}/${var.app_env}/artifact/${var.artifact_file_name}"
  metadata               = {
    "filesha256" = chomp(file("${var.artifact_folder_path}${var.artifact_file_name}.sha256"))
  }
  tags                   = {}
}