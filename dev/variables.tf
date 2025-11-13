variable "project_name" {
  type = string
}
variable "state_lock_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "mongodb_uri" {
  description = "MongoDB URI"
  type        = string
}

variable "cognito_domain_prefix" {
  description = "Unique domain prefix for Cognito Hosted UI"
  type        = string
}

variable "cognito_callback_urls" {
  description = "Allowed redirect URIs after login"
  type        = list(string)
  default     = ["https://app.example.com/callback", "http://localhost:3000/dashboard"]
}

variable "cognito_logout_urls" {
  description = "Allowed redirect URIs after logout"
  type        = list(string)
  default     = ["https://app.example.com/", "http://localhost:3000/auth/login"]
}

variable "microsoft_saml_metadata_url" {
  description = "Microsoft Entra ID SAML metadata URL (Federation Metadata)"
  type        = string
}

# Optional Resources
# The following values here should be defined on the start of the project,
# But can also be substituted via the tfvars file.
variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}
