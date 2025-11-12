# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "main_event_bus_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/event-bridge/main/bus/arn"
  description = "Event Bridge Main Bus ARN"
  type        = "String"
  value       = aws_cloudwatch_event_bus.main_bus.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "main_event_bus_name" {
  name        = "/${var.common.project_name}/${var.common.environment}/event-bridge/main/bus"
  description = "Event Bridge Main Bus"
  type        = "String"
  value       = aws_cloudwatch_event_bus.main_bus.name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
