locals {
  # These values are not included in tfvars file because these values will not cause security
  # issues. But always take note of tls_version and caching_policy_id as these values may
  # vary between aws accounts.
  admin_portal_origin_id = "AdminPortalS3Origin"
  tls_version            = "TLSv1.2_2021"
  caching_policy_id      = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "admin_frontend" {
  bucket = "${var.common.project_name}-${var.common.environment}-admin-frontend"
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_public_access_block" "admin_public_access_block" {
  bucket = aws_s3_bucket.admin_frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "admin_ownership" {
  bucket = aws_s3_bucket.admin_frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_cloudfront_origin_access_control" "admin_origin_access_control" {
  name                              = aws_s3_bucket.admin_frontend.bucket_regional_domain_name
  description                       = "Origin Access Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "admin_frontend_distribution" {
  origin {
    domain_name              = aws_s3_bucket.admin_frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.admin_origin_access_control.id
    origin_id                = local.admin_portal_origin_id

  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.common.project_name}-${var.common.environment}"
  default_root_object = "index.html"
  aliases             = [var.cloudfront_config.admin_portal_alias]
  price_class         = "PriceClass_All"
  ## Use a public bucket with ACL enabled for this
  # logging_config {
  #   include_cookies = false
  #   bucket          = #
  #   prefix          = "logs"
  # }
  default_cache_behavior {
    target_origin_id       = local.admin_portal_origin_id
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
    acm_certificate_arn      = var.cloudfront_config.aws_acm_arm
    minimum_protocol_version = local.tls_version
    ssl_support_method       = "sni-only"

  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_policy" "cloudfront_s3_admin_bucket_policy" {
  bucket = aws_s3_bucket.admin_frontend.id
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
        Resource = "${aws_s3_bucket.admin_frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.admin_frontend_distribution.arn
          }
        }
      }
    ]
  })
}
