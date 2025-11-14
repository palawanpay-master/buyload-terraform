resource "aws_vpc_endpoint" "custom_vpc_endpoint" {
  vpc_id              = var.params.vpc_id
  service_name        = "com.amazonaws.${var.common.region}.${var.params.service_name_suffix}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = var.params.subnet_ids
  security_group_ids = var.params.security_group_ids

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-vpce-${var.params.service_name_suffix}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
