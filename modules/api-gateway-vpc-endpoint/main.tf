resource "aws_vpc_endpoint" "execute_api" {
  vpc_id              = var.params.vpc_id
  service_name        = "com.amazonaws.${var.common.region}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = var.params.subnet_ids
  security_group_ids = var.params.security_group_ids

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-vpce-execute-api"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
