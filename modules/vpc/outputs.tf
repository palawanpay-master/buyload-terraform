# Module Parameters
# Define project variables for usability of other modules
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = var.vpc_config.vpc_cidr
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "private_rtb_ids" {
  value = aws_route_table.private_rtb[*].id
}
output "public_rtbs" {
  value = aws_route_table.public_rtb[*].id
}

