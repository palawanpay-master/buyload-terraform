locals {
  # These values are not included in tfvars file because these values will not cause security
  # issues. But always take note of tls_version and caching_policy_id as these values may
  # vary between aws accounts.
  s3_origin_id      = "S3PublicStorageOrigin"
  tls_version       = "TLSv1.2_2021"
  caching_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.common.project_name}-${var.common.environment}-public-bucket"

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "public_bucket_cors" {
  bucket = aws_s3_bucket.public_bucket.id
  cors_rule {
    allowed_headers = [
      "*"
    ]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_cloudfront_origin_access_control" "s3_public_origin_access_control" {
  name                              = aws_s3_bucket.public_bucket.bucket_regional_domain_name
  description                       = "Origin Access Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_public_distribution" {
  origin {
    domain_name              = aws_s3_bucket.public_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_public_origin_access_control.id
    origin_id                = local.s3_origin_id

  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.common.project_name}-${var.common.environment}"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  ## Use a public bucket with ACL enabled for this
  # logging_config {
  #   include_cookies = false
  #   bucket          = #
  #   prefix          = "logs"
  # }
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = local.caching_policy_id
  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
  custom_error_response {
    error_code            = 403           # Specify the HTTP error code
    response_code         = 200           # Specify the HTTP response code
    response_page_path    = "/index.html" # Specify the path to your custom error page
    error_caching_min_ttl = 60            # Specify the minimum time-to-live for the error response
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = local.tls_version
  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_policy" "cloudfront_s3_public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_public_distribution.arn
          }
        }
      }
    ]
  })
}
