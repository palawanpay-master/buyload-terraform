# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "public_bucket" {
  name        = "/${var.common.project_name}/${var.common.environment}/s3/public-bucket"
  description = "Public S3 Bucket"
  type        = "String"
  value       = aws_s3_bucket.public_bucket.bucket
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "s3_public_distribution_domain" {
  name  = "/${var.common.project_name}/${var.common.environment}/cloudfront/s3-public-distribution-domain"
  type  = "String"
  value = aws_cloudfront_distribution.s3_public_distribution.domain_name

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
