resource "aws_security_group" "web_app_alb_sg" {
  name        = "${var.common.project_name}-${var.common.environment}-web-app-alb-sg"
  description = "Web App ALB Security Group"
  vpc_id      = var.web_app_config.vpc_id

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

resource "aws_security_group" "web_app_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-web-app-sg"
  description = "Web App Security Group"
  vpc_id      = var.web_app_config.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_alb_sg.id]
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

resource "aws_iam_role" "web_app_role" {
  name                = "${var.common.project_name}-${var.common.environment}-web-app-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },

    ],
  })

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }

}

resource "aws_iam_instance_profile" "web_app_instance_profile" {
  name = "${var.common.project_name}-${var.common.environment}-web-app-instance-profile"
  role = aws_iam_role.web_app_role.name

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_instance" "web_app" {
  count                  = length(var.web_app_config.private_subnets)
  ami                    = var.web_app_config.ami
  instance_type          = var.web_app_config.instance_type
  iam_instance_profile   = aws_iam_instance_profile.web_app_instance_profile.name
  vpc_security_group_ids = [aws_security_group.web_app_security_group.id]
  subnet_id              = var.web_app_config.private_subnets[count.index]
  user_data              = var.web_app_config.user_data

  tags = {
    # This is where the ec2 name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-web-app${count.index + 1}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_lb" "web_app_alb" {
  name                       = "${var.common.project_name}-${var.common.environment}-web-app-alb"
  load_balancer_type         = "application"
  subnets                    = var.web_app_config.public_subnets
  security_groups            = [aws_security_group.web_app_alb_sg.id]
  enable_deletion_protection = false
  internal                   = false
  enable_http2               = true # Enable HTTP/2 for better performance

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-web-app-alb"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_lb_target_group" "web_app_target_group" {
  name     = "${var.common.project_name}-${var.common.environment}-web-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.web_app_config.vpc_id
  tags = {
    # This is where the ec2 name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-web-app-tg"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_lb_target_group_attachment" "web_app_tg_attachment" {
  count            = length(aws_instance.web_app)
  target_group_arn = aws_lb_target_group.web_app_target_group.arn
  target_id        = aws_instance.web_app[count.index].id
  port             = 80

}

resource "aws_lb_listener" "web_app_alb_http_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
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

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-web-app-alb-http-listener"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_lb_listener" "web_app_alb_https_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.web_app_config.acm_certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-web-app-alb-https-listener"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

