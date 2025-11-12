# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "execute_api_vpce_id" {
  name        = "/${var.common.project_name}/${var.common.environment}/network/vpce/execute-api/id"
  description = "API Gateway (execute-api) VPC Endpoint ID"
  type        = "String"
  value       = aws_vpc_endpoint.execute_api.id

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
