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

variable "params" {
  type = object({
    mongodb_uri        = string
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}
