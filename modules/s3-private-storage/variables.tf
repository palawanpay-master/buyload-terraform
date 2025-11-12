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

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket for private storage"
}

variable "create_ssm_parameter" {
  type        = bool
  description = "Whether to create the SSM parameter for the private S3 bucket"
}

variable "needs_versioning" {
  type        = bool
  description = "Whether to enable versioning on the S3 bucket"
  default     = false
}
