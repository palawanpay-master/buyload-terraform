
# Admin User Pool
resource "aws_cognito_user_pool" "admin" {
  name = "${var.common.project_name}-${var.common.environment}-admin-user-pool"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

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

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 64
    }
  }
  tags = {
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_cognito_user_pool_domain" "admin_domain" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.admin.id
}

resource "aws_cognito_identity_provider" "microsoft_saml" {
  user_pool_id  = aws_cognito_user_pool.admin.id
  provider_name = "MICROSOFT-SAML" # you'll reference this in the client
  provider_type = "SAML"

  provider_details = {
    MetadataURL = var.microsoft_saml_metadata_url
    IDPSignout  = "true"
  }

  attribute_mapping = {
    email              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    given_name         = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    family_name        = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
    preferred_username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    phone_number       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone"
  }
}

# Admin User Pool Client
resource "aws_cognito_user_pool_client" "admin_client" {
  name         = "${var.common.project_name}-${var.common.environment}-admin-user-pool-client"
  user_pool_id = aws_cognito_user_pool.admin.id


  # Hosted UI / OAuth
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"] # or ["code", "implicit"]
  allowed_oauth_scopes = ["openid", "email", "profile", "aws.cognito.signin.user.admin",
    # BUYLOAD main service
    "${aws_cognito_resource_server.buyload_service.identifier}/product.read",
    "${aws_cognito_resource_server.buyload_service.identifier}/payment.process",
    "${aws_cognito_resource_server.buyload_service.identifier}/payment.reverse",
    "${aws_cognito_resource_server.buyload_service.identifier}/payment.read",
    "${aws_cognito_resource_server.buyload_service.identifier}/payment.inquire",
    "${aws_cognito_resource_server.buyload_service.identifier}/payment.verify",

    # CATALOG service
    "${aws_cognito_resource_server.catalog_service.identifier}/sku.read",
    "${aws_cognito_resource_server.catalog_service.identifier}/category.update",
    "${aws_cognito_resource_server.catalog_service.identifier}/brand.read",
    "${aws_cognito_resource_server.catalog_service.identifier}/skumap.delete",
    "${aws_cognito_resource_server.catalog_service.identifier}/sku.create",
    "${aws_cognito_resource_server.catalog_service.identifier}/skumap.read",
    "${aws_cognito_resource_server.catalog_service.identifier}/category.create",
    "${aws_cognito_resource_server.catalog_service.identifier}/brand.create",
    "${aws_cognito_resource_server.catalog_service.identifier}/skumap.update",
    "${aws_cognito_resource_server.catalog_service.identifier}/skumap.create",
    "${aws_cognito_resource_server.catalog_service.identifier}/brand.update",
    "${aws_cognito_resource_server.catalog_service.identifier}/category.read",
    "${aws_cognito_resource_server.catalog_service.identifier}/category.delete",
    "${aws_cognito_resource_server.catalog_service.identifier}/sku.update",
    "${aws_cognito_resource_server.catalog_service.identifier}/sku.delete",
    "${aws_cognito_resource_server.catalog_service.identifier}/brand.delete",

    # FILE service
    "${aws_cognito_resource_server.file_service.identifier}/file.create",

    # PROVIDER service
    "${aws_cognito_resource_server.provider_service.identifier}/aggregator.read",
    "${aws_cognito_resource_server.provider_service.identifier}/package.read",
    "${aws_cognito_resource_server.provider_service.identifier}/systemconfig.create",
    "${aws_cognito_resource_server.provider_service.identifier}/aggregator.create",
    "${aws_cognito_resource_server.provider_service.identifier}/package.update",
    "${aws_cognito_resource_server.provider_service.identifier}/aggregator.delete",
    "${aws_cognito_resource_server.provider_service.identifier}/package.create",
    "${aws_cognito_resource_server.provider_service.identifier}/package.delete",
    "${aws_cognito_resource_server.provider_service.identifier}/aggregator.update",
    "${aws_cognito_resource_server.provider_service.identifier}/systemconfig.read",
  ]

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  # Allow both Cognito (username/email) and Microsoft SAML
  supported_identity_providers = [
    "COGNITO",
    aws_cognito_identity_provider.microsoft_saml.provider_name,
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30


  # optional: to allow SRP / admin auth etc.
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
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


# --------------------------------------
# Resource Servers (API resource + scopes)
# These correspond to what you see in the "Resource servers" tab
# --------------------------------------

# BUYLOAD main service
resource "aws_cognito_resource_server" "buyload_service" {
  user_pool_id = aws_cognito_user_pool.admin.id
  name         = "${var.common.project_name}-buyload-service-api-resource"
  identifier   = "${var.common.project_name}-buyload-service-api"

  # ✏️ Replace scope_name values with the real ones you use
  scope {
    scope_name        = "product.read"
    scope_description = "Read product data"
  }

  scope {
    scope_name        = "payment.process"
    scope_description = "Process payment"
  }
  scope {
    scope_name        = "payment.reverse"
    scope_description = "Reverse payment"
  }
  scope {
    scope_name        = "payment.read"
    scope_description = "Read payment status"
  }

  scope {
    scope_name        = "payment.inquire"
    scope_description = "Inquire payment"
  }

  scope {
    scope_name        = "payment.verify"
    scope_description = "Verify payment"
  }
}

# CATALOG service
resource "aws_cognito_resource_server" "catalog_service" {
  user_pool_id = aws_cognito_user_pool.admin.id
  name         = "${var.common.project_name}-catalog-service-api-resource"
  identifier   = "${var.common.project_name}-catalog-service-api"

  scope {
    scope_name        = "sku.read"
    scope_description = "Read SKU"
  }

  scope {
    scope_name        = "category.update"
    scope_description = "Update category"
  }

  scope {
    scope_name        = "brand.read"
    scope_description = "Read brand"
  }

  scope {
    scope_name        = "skumap.delete"
    scope_description = "Delete SKU map"
  }

  scope {
    scope_name        = "sku.create"
    scope_description = "Create SKU"
  }

  scope {
    scope_name        = "skumap.read"
    scope_description = "Create SKU"
  }

  scope {
    scope_name        = "category.create"
    scope_description = "Create category"
  }

  scope {
    scope_name        = "brand.create"
    scope_description = "Create brand"
  }

  scope {
    scope_name        = "skumap.update"
    scope_description = "Update SKU map"
  }

  scope {
    scope_name        = "skumap.create"
    scope_description = "Create SKU map"
  }

  scope {
    scope_name        = "brand.update"
    scope_description = "Update brand"
  }

  scope {
    scope_name        = "category.read"
    scope_description = "Read category"
  }

  scope {
    scope_name        = "category.delete"
    scope_description = "Delete category"
  }

  scope {
    scope_name        = "sku.update"
    scope_description = "Update SKU"
  }

  scope {
    scope_name        = "sku.delete"
    scope_description = "Delete SKU"
  }

  scope {
    scope_name        = "brand.delete"
    scope_description = "Delete brand"
  }
}

# FILE service
resource "aws_cognito_resource_server" "file_service" {
  user_pool_id = aws_cognito_user_pool.admin.id
  name         = "${var.common.project_name}-file-service-api-resource"
  identifier   = "${var.common.project_name}-file-service-api"

  scope {
    scope_name        = "file.create"
    scope_description = "Upload file"
  }
}

# PROVIDER service
resource "aws_cognito_resource_server" "provider_service" {
  user_pool_id = aws_cognito_user_pool.admin.id
  name         = "${var.common.project_name}-provider-service-api-resource"
  identifier   = "${var.common.project_name}-provider-service-api"

  scope {
    scope_name        = "aggregator.read"
    scope_description = "Read aggregator"
  }

  scope {
    scope_name        = "package.read"
    scope_description = "Read package"
  }

  scope {
    scope_name        = "systemconfig.create"
    scope_description = "Create system configuration"
  }

  scope {
    scope_name        = "aggregator.create"
    scope_description = "Create aggregator"
  }

  scope {
    scope_name        = "package.update"
    scope_description = "Update package"
  }

  scope {
    scope_name        = "aggregator.delete"
    scope_description = "Delete aggregator"
  }

  scope {
    scope_name        = "package.create"
    scope_description = "Create package"
  }

  scope {
    scope_name        = "package.delete"
    scope_description = "Delete package"
  }

  scope {
    scope_name        = "aggregator.update"
    scope_description = "Update aggregator"
  }

  scope {
    scope_name        = "systemconfig.read"
    scope_description = "Read system configuration"
  }
}
