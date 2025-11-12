# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "auth_request_table_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/ddb/auth-request-table/arn"
  description = "DDB Auth request table ARN"
  type        = "String"
  value       = aws_dynamodb_table.auth_request_table.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "auth_request_table_name" {
  name        = "/${var.common.project_name}/${var.common.environment}/ddb/auth-request-table/name"
  description = "DDB Auth request table name"
  type        = "String"
  value       = aws_dynamodb_table.auth_request_table.name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "shared_table_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/ddb/shared-table/arn"
  description = "DDB Shared request table ARN"
  type        = "String"
  value       = aws_dynamodb_table.shared_table.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "shared_table_name" {
  name        = "/${var.common.project_name}/${var.common.environment}/ddb/shared-table/name"
  description = "DDB Shared request table name"
  type        = "String"
  value       = aws_dynamodb_table.shared_table.name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
