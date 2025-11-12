# Admin User Pool
resource "aws_cognito_user_pool" "admin" {
  name = "${var.common.project_name}-${var.common.environment}-admin-user-pool"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "INACTIVE"
  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }
  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }
  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 3
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Admin User Pool Client
resource "aws_cognito_user_pool_client" "admin_client" {
  name         = "${var.common.project_name}-${var.common.environment}-admin-user-pool-client"
  user_pool_id = aws_cognito_user_pool.admin.id
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30
}

# Admin Identity Pool
resource "aws_cognito_identity_pool" "admin_identity_pool" {
  identity_pool_name               = "${var.common.project_name}-${var.common.environment}-admin-identity-pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.admin_client.id
    provider_name           = "cognito-idp.${var.common.region}.amazonaws.com/${aws_cognito_user_pool.admin.id}"
    server_side_token_check = false
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Admin Authenticated Role
resource "aws_iam_role" "admin_authenticated_role" {
  name = "${var.common.project_name}-${var.common.environment}-admin-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.admin_identity_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "admin_authenticated_role_policy" {
  name = "${var.common.project_name}-${var.common.environment}-admin-authenticated-policy"
  role = aws_iam_role.admin_authenticated_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*",
      },
    ]
  })
}

# Admin Authenticated Role Mapping
resource "aws_cognito_identity_pool_roles_attachment" "admin_identity_pool_role_mapping" {
  identity_pool_id = aws_cognito_identity_pool.admin_identity_pool.id
  roles = {
    authenticated = aws_iam_role.admin_authenticated_role.arn
  }
}
