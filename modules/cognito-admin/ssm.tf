# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "admin_user_pool_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/cognito/admin-user-pool/arn"
  description = "Cognito Admin User Pool ARN"
  type        = "String"
  value       = aws_cognito_user_pool.admin.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
