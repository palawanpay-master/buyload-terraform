# Module Parameters
# Define project variables for usability of other modules
output "execute_api_vpc_endpoint_id" {
  value = aws_vpc_endpoint.custom_vpc_endpoint.id
}
