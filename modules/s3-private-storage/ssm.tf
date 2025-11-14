resource "aws_ssm_parameter" "private_bucket" {
  name        = "/${var.common.project_name}/${var.common.environment}/s3/${var.bucket_name}"
  count       = var.create_ssm_parameter ? 1 : 0
  description = "Private S3 Bucket"
  type        = "String"
  value       = aws_s3_bucket.private_bucket.bucket
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
