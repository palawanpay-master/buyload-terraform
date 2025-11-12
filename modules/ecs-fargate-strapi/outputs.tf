# Module Parameters
# Define project variables for usability of other modules


output "security_group_id" {
  value = aws_security_group.strapi_service_security_group.id
}



