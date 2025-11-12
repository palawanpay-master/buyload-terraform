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

# This bastion is accessed via SSM 
variable "strapi_config" {
  type = object({
    vpc_id              = string
    public_subnets      = list(string)
    private_subnets     = list(string)
    acm_certificate_arn = string
  })
}
