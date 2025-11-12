resource "aws_security_group" "strapi_alb_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-strapi-alb-sg"
  description = "Strapi ALB ECS Security Groups"
  vpc_id      = var.strapi_config.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_security_group" "strapi_service_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-strapi-service-sg"
  description = "Strapi Service Security Group"
  vpc_id      = var.strapi_config.vpc_id

  ingress {
    from_port       = 1337 # Change to desired port of app
    to_port         = 1337 # Change to desired port of app
    protocol        = "tcp"
    security_groups = [aws_security_group.strapi_alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_cloudwatch_log_group" "strapi_log_group" {
  name = "/ecs/${var.common.project_name}-${var.common.environment}-strapi-logs"
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ecr_repository" "strapi_repository" {
  name                 = "${var.common.project_name}-${var.common.environment}-strapi-repository"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "${var.common.project_name}-${var.common.environment}-strapi-cluster"
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "strapi_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.strapi_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

resource "aws_iam_role" "strapi_task_execution_role" {
  name = "${var.common.project_name}-${var.common.environment}-strapi-task-execution-role"

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
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_iam_role_policy" "strapi_task_execution_role_policy" {
  name = "${var.common.project_name}-${var.common.environment}-strapi-execution-policy"
  role = aws_iam_role.strapi_task_execution_role.id

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

resource "aws_ecs_task_definition" "strapi_task_definition" {
  family                   = "${var.common.project_name}-${var.common.environment}-strapi-td-family"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.strapi_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name        = "${var.common.project_name}-${var.common.environment}-strapi-container"
    image       = "${aws_ecr_repository.strapi_repository.repository_url}:latest"
    cpu         = 256
    memory      = 512
    essential   = true
    environment = []
    portMappings = [{
      containerPort = 1337 # Change to exposed port of app
      hostPort      = 1337 # Change to exposed port of app
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.strapi_log_group.name
        "awslogs-region"        = var.common.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_alb" "strapi_alb" {
  name                       = "${var.common.project_name}-${var.common.environment}-strapi-alb"
  load_balancer_type         = "application"
  subnets                    = var.strapi_config.public_subnets
  security_groups            = [aws_security_group.strapi_alb_security_group.id]
  enable_deletion_protection = false
  internal                   = false
  enable_http2               = true # Enable HTTP/2 for better performance

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-strapi-alb"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_alb_target_group" "strapi_alb_target_group" {
  name        = "${var.common.project_name}-${var.common.environment}-strapi-alb-tg"
  port        = 1337 # Change to desired port of container
  protocol    = "HTTP"
  vpc_id      = var.strapi_config.vpc_id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = 1337 # Change to desired port of container
    protocol = "HTTP"
    matcher  = "200"
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_alb_listener" "strapi_http_listener" {
  load_balancer_arn = aws_alb.strapi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_alb_target_group.strapi_alb_target_group.arn
  # }

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-strapi-alb-http-listener"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_lb_listener" "strapi_alb_https_listener" {
  load_balancer_arn = aws_alb.strapi_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.strapi_config.acm_certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.strapi_alb_target_group.arn
  }

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-strapi-alb-https-listener"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_ecs_service" "strapi_service" {
  name                 = "${var.common.project_name}-${var.common.environment}-strapi-service"
  cluster              = aws_ecs_cluster.strapi_cluster.id
  task_definition      = aws_ecs_task_definition.strapi_task_definition.arn
  launch_type          = "FARGATE"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets         = var.strapi_config.private_subnets
    security_groups = [aws_security_group.strapi_service_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.strapi_alb_target_group.arn
    container_name   = "${var.common.project_name}-${var.common.environment}-strapi-container"
    container_port   = 1337 # Change to desired port of container
  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
