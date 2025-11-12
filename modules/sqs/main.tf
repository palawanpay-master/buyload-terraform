resource "aws_sqs_queue" "reset_password_queue" {
  name                        = "reset-password-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 300

  delay_seconds               = 0
  receive_wait_time_seconds   = 0

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
