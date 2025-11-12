# SSM Parameters
# Defined project configurations

resource "aws_ssm_parameter" "mongodb_uri" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/mongodb/uri"
  description = "MongoDB URI"
  type        = "SecureString"
  value       = var.params.mongodb_uri
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "mongodb_uri_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/external/mongodb/uri/arn"
  description = "MongoDB URI ARN"
  type        = "String"
  value       = aws_ssm_parameter.mongodb_uri.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "security_group_ids" {
  for_each = {
    for index, sg_id in var.params.security_group_ids : index => sg_id
  }

  name        = "/${var.common.project_name}/${var.common.environment}/external/security-groups/${each.key}"
  description = "Security Group ID ${each.key}"
  type        = "String"
  value       = each.value

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "subnet_ids" {
  for_each = {
    for index, subnet_id in var.params.subnet_ids : index => subnet_id
  }

  name        = "/${var.common.project_name}/${var.common.environment}/external/subnets/${each.key}"
  description = "Subnet ID ${each.key}"
  type        = "String"
  value       = each.value

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
