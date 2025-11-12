# SSM Parameters
# Defined project configurations

resource "aws_ssm_parameter" "main_rds_secret_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/rds/secret/arn"
  description = "RDS Secret Arn"
  type        = "String"
  value       = aws_db_instance.main_rds.master_user_secret[0].secret_arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "main_rds_db_name" {
  name        = "/${var.common.project_name}/${var.common.environment}/rds/db/name"
  description = "RDS Database Name"
  type        = "String"
  value       = aws_db_instance.main_rds.db_name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "main_rds_port" {
  name        = "/${var.common.project_name}/${var.common.environment}/rds/port"
  description = "RDS Port"
  type        = "String"
  value       = 5432
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "main_rds_host" {
  name        = "/${var.common.project_name}/${var.common.environment}/rds/host"
  description = "RDS Proxy Host"
  type        = "String"
  value       = var.db_config.publicly_accessible ? aws_db_instance.main_rds.address : element(aws_db_proxy.rds_proxy.*.endpoint, 0)
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
