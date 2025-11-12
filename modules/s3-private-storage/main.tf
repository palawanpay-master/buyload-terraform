
resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.common.project_name}-${var.common.environment}-private-${var.bucket_name}"

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_s3_bucket_cors_configuration" "private_bucket_cors" {
  bucket = aws_s3_bucket.private_bucket.id
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

resource "aws_s3_bucket_versioning" "private_bucket_versioning" {
  count  = var.needs_versioning ? 1 : 0
  bucket = aws_s3_bucket.private_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
