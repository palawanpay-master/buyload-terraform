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
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}

# This VPC module provisions the following
# - VPC
# - Number of AZ is dependent on the provided number of subnets
# - 1 Internet Gateway (Fixed only 1 IGW is needed)
# - nat_gateway_availability_zones allows 2 values, single and all (Configurable on vpc_config)
#   - If single it will provision 1 EIP and 1 NAT Gateway
#   - If all number of provisiong EIP and Nat Gateway will depend on the number of private subnets
# - 1 public route table will be provisioned
#   - 2 routes will be configured for local and igw
#   - route table will be associated with the total number of public subnets
# - The number of private route tables will depend on the number of private subnets
#   - All route table will have a default local route and VPC endpoint s3 route
#   - If nat_gateway_availability_zone is single, all private route table routes will use the same natgw config
#   - If nat_gateway_availability_zone is all, each route table route will be configured with their own natgw config
variable "vpc_config" {
  type = object({
    vpc_cidr                       = string
    public_subnet_cidrs            = list(string)
    private_subnet_cidrs           = list(string)
    availability_zones             = list(string)
    nat_gateway_availability_zones = string
  })
}
