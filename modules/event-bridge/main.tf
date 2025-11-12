resource "aws_cloudwatch_event_bus" "main_bus" {
  name = "${var.common.project_name}-${var.common.environment}-main-bus"
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
