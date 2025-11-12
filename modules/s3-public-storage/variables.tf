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

variable "variables" {
  type = object({
    add_bucket_policy = bool
  })
}
