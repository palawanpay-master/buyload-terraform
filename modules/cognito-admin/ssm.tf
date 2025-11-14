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
resource "aws_ssm_parameter" "admin_user_pool_id" {
  name        = "/${var.common.project_name}/${var.common.environment}/cognito/admin-user-pool/id"
  description = "Cognito Admin User Pool ID"
  type        = "String"
  value       = aws_cognito_user_pool.admin.id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "admin_user_pool_client_id" {
  name        = "/${var.common.project_name}/${var.common.environment}/cognito/admin-user-pool/client-id"
  description = "Cognito Admin User Pool App Client ID"
  type        = "String"
  value       = aws_cognito_user_pool_client.admin_client.id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
