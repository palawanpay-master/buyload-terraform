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
    service_name_suffix = string
    vpc_id              = string
    subnet_ids          = list(string)
    security_group_ids  = list(string)
  })
}

