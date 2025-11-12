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
