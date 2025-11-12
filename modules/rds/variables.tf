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

variable "db_config" {
  type = object({
    database_name                         = string
    username                              = string
    manage_master_user_password           = bool
    engine                                = string
    engine_version                        = string
    instance_class                        = string
    port                                  = number
    storage_type                          = string
    allocated_storage                     = number
    max_allocated_storage                 = number
    iops                                  = any
    publicly_accessible                   = bool
    multi_az                              = bool
    vpc_id                                = string
    vpc_subnet_ids                        = list(string)
    additional_ingress_security_groups    = list(string)
    additional_ingress_cidr_blocks        = list(string)
    availability_zone                     = string
    ca_cert_identifier                    = string
    performance_insights_enabled          = bool
    performance_insights_retention_period = number
    backup_retention_period               = number
    backup_window                         = string
    maintenance_window                    = string
    copy_tags_to_snapshot                 = bool
    monitoring_interval                   = number
    deletion_protection                   = bool
    skip_final_snapshot                   = bool
  })
}
variable "db_proxy_config" {
  type = object({
    engine_family                      = string
    client_password_auth_type          = string
    iam_auth                           = string
    debug_logging                      = bool
    idle_client_timeout                = number
    connection_borrow_timeout          = number
    max_connections_percent            = number
    additional_ingress_security_groups = list(string)
  })
}
