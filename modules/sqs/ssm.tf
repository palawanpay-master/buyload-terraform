# Store SQS ARN in SSM Parameter Store
resource "aws_ssm_parameter" "reset_password_queue_arn" {
  name  = "/${var.common.project_name}/${var.common.environment}/sqs/reset-password-queue/arn"
  type  = "String"
  value = aws_sqs_queue.reset_password_queue.arn
}

# Store SQS URL in SSM Parameter Store
resource "aws_ssm_parameter" "reset_password_queue_url" {
  name  = "/${var.common.project_name}/${var.common.environment}/sqs/reset-password-queue/url"
  type  = "String"
  value = aws_sqs_queue.reset_password_queue.url
}
