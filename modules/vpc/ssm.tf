# SSM Parameters
# Defined project configurations
resource "aws_ssm_parameter" "private_subnet_ids" {
  count       = length(aws_subnet.private_subnet)
  name        = "/${var.common.project_name}/${var.common.environment}/private/subnet/${count.index + 1}"
  description = "Private subnet ${count.index + 1}"
  type        = "String"
  value       = aws_subnet.private_subnet[count.index].id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  count       = length(aws_subnet.public_subnet)
  name        = "/${var.common.project_name}/${var.common.environment}/public/subnet/${count.index + 1}"
  description = "Public subnet ${count.index + 1}"
  type        = "String"
  value       = aws_subnet.public_subnet[count.index].id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
