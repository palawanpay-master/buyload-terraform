# Uncomment this if you are using Bastion
resource "aws_security_group" "bastion_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-bastion-sg"
  description = "Bastion Security Group"
  vpc_id      = var.bastion_config.vpc_id

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

resource "aws_iam_role" "bastion_role" {
  name = "${var.common.project_name}-${var.common.environment}-bastion-role"
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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.common.project_name}-${var.common.environment}-bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.bastion_config.ami
  instance_type          = var.bastion_config.instance_type
  iam_instance_profile   = aws_iam_instance_profile.bastion_instance_profile.name
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = var.bastion_config.subnet_id
  user_data              = var.bastion_config.user_data

  tags = {
    # This is where the ec2 name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-bastion"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
