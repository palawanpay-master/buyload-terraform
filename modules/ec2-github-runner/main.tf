# Uncomment this if you are using Github Runner
resource "aws_security_group" "github_runner_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-github-runner-sg"
  description = "Github Runner Security Group"
  vpc_id      = var.github_runner_config.vpc_id

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

resource "aws_iam_role" "github_runner_role" {
  name                = "${var.common.project_name}-${var.common.environment}-github-runner-role"
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
    # This is where the ec2 name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-github-runner"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }

}

resource "aws_iam_instance_profile" "github_runner_instance_profile" {
  name = "${var.common.project_name}-${var.common.environment}-github-runner-instance-profile"
  role = aws_iam_role.github_runner_role.name

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_instance" "github_runner" {
  ami                    = var.github_runner_config.ami
  instance_type          = var.github_runner_config.instance_type
  iam_instance_profile   = aws_iam_instance_profile.github_runner_instance_profile.name
  vpc_security_group_ids = [aws_security_group.github_runner_security_group.id]
  subnet_id              = var.github_runner_config.subnet_id
  user_data              = var.github_runner_config.user_data

  tags = {
    # This is where the ec2 name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-github-runner"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
