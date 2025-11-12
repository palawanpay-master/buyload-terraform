# SSM Parameters
# Defined project configurations

resource "aws_ssm_parameter" "lambda_security_group" {
  name        = "/${var.common.project_name}/${var.common.environment}/lambda/sg"
  description = "Lambda Security Group"
  type        = "String"
  value       = aws_security_group.lambda_security_group.id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "lambda_role_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/lambda/role/arn"
  description = "Lambda Role ARN"
  type        = "String"
  value       = aws_iam_role.lambda_role.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
