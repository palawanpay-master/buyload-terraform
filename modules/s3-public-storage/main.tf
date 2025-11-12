
resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.common.project_name}-${var.common.environment}-public-bucket"

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_public_access_block" "admin_public_access_block" {
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

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  count  = var.variables.add_bucket_policy ? 1 : 0
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "GetPolicy"
    Statement = [
      {
        Sid       = "AllowGetPolicy"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.public_bucket.arn}/*",
          "${aws_s3_bucket.public_bucket.arn}"
        ]
      }
    ]
  })
}
