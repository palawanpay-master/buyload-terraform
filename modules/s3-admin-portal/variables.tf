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

variable "cloudfront_config" {
  type = object({
    aws_acm_arm        = string
    admin_portal_alias = string
  })
}
