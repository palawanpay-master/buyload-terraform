resource "aws_dynamodb_table" "auth_request_table" {
  name         = "${var.common.project_name}-${var.common.environment}-auth-request-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "request_token"
  attribute {
    name = "user_id"
    type = "S"
  }
  attribute {
    name = "request_token"
    type = "S"
  }
  ttl {
    attribute_name = "created_at"
    enabled        = true
  }

  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_dynamodb_table" "shared_table" {
  name         = "${var.common.project_name}-${var.common.environment}-shared-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"
  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
