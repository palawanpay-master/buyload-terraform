# [MANDATORY] 
#  - Define common for consuming shared parameters
#  - Omit any parameters that are not needed
variable "common" {
  type = object({
    project_name = string
    environment  = string
    region       = string
  })
}

variable "cognito_domain_prefix" {
  description = "Unique domain prefix for Cognito Hosted UI"
  type        = string
}

variable "cognito_callback_urls" {
  description = "Allowed redirect URIs after login"
  type        = list(string)
  default     = ["https://app.example.com/callback"]
}

variable "cognito_logout_urls" {
  description = "Allowed redirect URIs after logout"
  type        = list(string)
  default     = ["https://app.example.com/"]
}

variable "microsoft_saml_metadata_url" {
  description = "Microsoft Entra ID SAML metadata URL (Federation Metadata)"
  type        = string
}
