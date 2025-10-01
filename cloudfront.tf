# CloudFront Default Cache Behavior Policy
resource "aws_cloudfront_cache_policy" "default" {
  count                          = var.cloudfront_create ? 1 : 0
  comment                        = "Policy with caching disabled"
  default_ttl                    = 0
  max_ttl                        = 0
  name                           = "Managed-CachingDisabled"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# CloudFront Ordered Cache Behavior Policy
resource "aws_cloudfront_cache_policy" "ordered" {
  count                          = var.cloudfront_create ? 1 : 0
  comment                        = "Policy with caching enabled. Supports Gzip and Brotli compression."
  min_ttl                        = 1
  name                           = "Managed-CachingOptimized"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "default" {
  count                          = var.cloudfront_create ? 1 : 0
  comment                        = "Policy to forward all parameters in viewer requests except for the Host header"
  name                           = "Managed-AllViewerExceptHostHeader"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "allExcept"

    headers {
      items = [
        "host",
      ]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_origin_access_control" "storage" {
  count                             = var.cloudfront_create ? 1 : 0
  description                       = "Origin Access Control for serving ${var.application_name} static assets from an S3 bucket"
  name                              = "${var.application_slug}-${var.app_env}-storage-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  count                          = var.cloudfront_create ? 1 : 0
  aliases                        = var.cloudfront_aliases
  comment                        = "Cloudfron Distribution for ${var.app_env} environment of ${var.application_name}"
  enabled                        = true
  is_ipv6_enabled                = true
  price_class                    = "PriceClass_All"
  tags                           = {
    "Name" = "${var.application_slug}-${var.app_env}-cloudfront-distribution"
  }

  default_cache_behavior {
    allowed_methods            = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods             = [
      "GET",
      "HEAD",
    ]
    cache_policy_id            = aws_cloudfront_cache_policy.default[0].id
    compress                   = true
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.default[0].id
    target_origin_id           = replace(aws_apigatewayv2_api.web.api_endpoint, "https://", "")
    viewer_protocol_policy     = "allow-all"
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.s3_bucket_storage_create ? [1] : []
    content {
      allowed_methods            = [
        "GET",
        "HEAD",
      ]
      cache_policy_id            = aws_cloudfront_cache_policy.ordered[0].id
      cached_methods             = [
        "GET",
        "HEAD",
      ]
      compress                   = true
      path_pattern               = "/css/*"
      target_origin_id           = aws_s3_bucket.storage[0].bucket_regional_domain_name
      viewer_protocol_policy     = "redirect-to-https"
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.s3_bucket_storage_create ? [1] : []
    content {
      allowed_methods            = [
        "GET",
        "HEAD",
      ]
      cache_policy_id            = aws_cloudfront_cache_policy.ordered[0].id
      cached_methods             = [
        "GET",
        "HEAD",
      ]
      compress                   = true
      path_pattern               = "/js/*"
      target_origin_id           = aws_s3_bucket.storage[0].bucket_regional_domain_name
      viewer_protocol_policy     = "redirect-to-https"
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.s3_bucket_storage_create ? [1] : []
    content {
      allowed_methods            = [
        "GET",
        "HEAD",
      ]
      cache_policy_id            = aws_cloudfront_cache_policy.ordered[0].id
      cached_methods             = [
        "GET",
        "HEAD",
      ]
      compress                   = true
      path_pattern               = "/favicon.ico"
      target_origin_id           = aws_s3_bucket.storage[0].bucket_regional_domain_name
      viewer_protocol_policy     = "redirect-to-https"
    }
  }
  dynamic "ordered_cache_behavior" {
    for_each = var.s3_bucket_storage_create ? [1] : []
    content {
      allowed_methods            = [
        "GET",
        "HEAD",
      ]
      cache_policy_id            = aws_cloudfront_cache_policy.ordered[0].id
      cached_methods             = [
        "GET",
        "HEAD",
      ]
      compress                   = true
      path_pattern               = "/robots.txt"
      target_origin_id           = aws_s3_bucket.storage[0].bucket_regional_domain_name
      viewer_protocol_policy     = "redirect-to-https"
    }
  }

  origin {
    domain_name              = replace(aws_apigatewayv2_api.web.api_endpoint, "https://", "")
    origin_id                = replace(aws_apigatewayv2_api.web.api_endpoint, "https://", "")

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = [
        "TLSv1.2",
      ]
    }
  }
  dynamic "origin" {
    for_each = var.s3_bucket_storage_create ? [1] : []
    content {
      domain_name              = aws_s3_bucket.storage[0].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.storage[0].id
      origin_id                = aws_s3_bucket.storage[0].bucket_regional_domain_name
      origin_path              = "/public"
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn            = var.acm_certificate_arn
      cloudfront_default_certificate = false
      iam_certificate_id             = null
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }
}