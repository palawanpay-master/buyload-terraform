resource "aws_security_group" "lambda_security_group" {
  name        = "${var.common.project_name}-${var.common.environment}-lambda-sg"
  description = "Lambda Security Group"
  vpc_id      = var.lambda_config.vpc_id

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

resource "aws_iam_role" "lambda_role" {
  name = "${var.common.project_name}-${var.common.environment}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DynamoDBPolicy",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource = "*"
      },
      {
        Sid    = "S3Policy",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      },
      {
        Sid    = "SSMPolicy",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      },
      {
        Sid    = "EventsPolicy",
        Effect = "Allow",
        Action = [
          "events:PutEvents",
          "events:DescribeRule",
          "events:ListTargetsByRule"
        ],
        Resource = "*"
      },
      {
        Sid    = "SecretsPolicy",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },
      {
        Sid    = "LambdaPolicy",
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunctionConfiguration",
          "apigateway:PUT"
        ],
        Resource = "*"
      },
      {
        Sid    = "CommunicationPolicy",
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "mobiletargeting:SendMessages"
        ],
        Resource = "*"
      },
      {
        Sid    = "CognitoPolicy",
        Effect = "Allow",
        Action = [
          "cognito-idp:*",
        ],
        Resource = "*"
      },
      {
        Sid    = "CloudWatchPolicy",
        Effect = "Allow",
        Action = [
          "cloudwatch:*",
        ],
        Resource = "*"
      },
      {
        Sid    = "SQSPolicy",
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues",
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:SendMessageBatch",
          "sqs:ReceiveMessageBatch",
          "sqs:DeleteMessageBatch",
          "sqs:GetQueueUrl",
          "sqs:ListQueueTags",
          "sqs:TagQueue",
          "sqs:UntagQueue",
          "sqs:ChangeMessageVisibility",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:ListQueueTags",
        ],
        Resource = "*",
      },
      {
        Sid    = "IAMPolicy",
        Effect = "Allow",
        Action = [
          "iam:PassRole",
        ],
        Resource = "*"
      },
    ]
  })
}

# Attach the AWSLambdaVPCAccessExecutionRole managed policy (for VPC access)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
