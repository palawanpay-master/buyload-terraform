resource "aws_security_group" "task_runner_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-task-runner-sg"
  description = "Task Runner Security Group"
  vpc_id      = var.task_runner_config.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "task_runner_cluster" {
  name = "${var.common.project_name}-${var.common.environment}-task-runner-cluster"
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "task_runner_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.task_runner_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

resource "aws_iam_role" "task_runner_role" {
  name = "${var.common.project_name}-${var.common.environment}-task-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com",
      },
      Action = "sts:AssumeRole",
    }],
  })
}

resource "aws_iam_role_policy" "task_runner_role_policy" {
  name = "${var.common.project_name}-${var.common.environment}-ecs-execution-policy"
  role = aws_iam_role.task_runner_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "ses:*",
          "cognito-idp:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "events:putEvents"
        ],
        Resource = "*",
      }
    ]
  })
}
