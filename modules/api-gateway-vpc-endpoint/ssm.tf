# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "custom_vpc_endpoint_id" {
  name        = "/${var.common.project_name}/${var.common.environment}/network/vpce/${var.params.service_name_suffix}/id"
  description = "Custom VPC Endpoint ID"
  type        = "String"
  value       = aws_vpc_endpoint.custom_vpc_endpoint.id

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
