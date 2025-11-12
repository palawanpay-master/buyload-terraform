resource "aws_ssm_parameter" "cluster_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/task-runner/cluster/arn"
  description = "Task Runner Cluster Name"
  type        = "String"
  value       = aws_ecs_cluster.task_runner_cluster.name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "task_runner_role_arn" {
  name        = "/${var.common.project_name}/${var.common.environment}/task-runner/role/arn"
  description = "Task Runner Role ARN"
  type        = "String"
  value       = aws_iam_role.task_runner_role.arn
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ssm_parameter" "task_runner_security_group" {
  name        = "/${var.common.project_name}/${var.common.environment}/task-runner/sg"
  description = "Task Runner Security Group"
  type        = "String"
  value       = aws_security_group.task_runner_security_group.id
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
