resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_config.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    # This is where the VPC name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-vpc"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.vpc_config.public_subnet_cidrs)
  cidr_block              = var.vpc_config.public_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.vpc_config.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    # This is where the public subnet is defined
    Name             = "${var.common.project_name}-${var.common.environment}-subnet-public${count.index + 1}-${var.vpc_config.availability_zones[count.index]}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }

}

resource "aws_subnet" "private_subnet" {
  count             = length(var.vpc_config.private_subnet_cidrs)
  cidr_block        = var.vpc_config.private_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.vpc_config.availability_zones[count.index]
  tags = {
    # This is where the private subnet name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-subnet-private${count.index + 1}-${var.vpc_config.availability_zones[count.index]}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Create Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    # This is where the igw name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-igw"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}


# Create Elastic IP for Nat Gateway
resource "aws_eip" "nat_eip" {
  count  = var.vpc_config.nat_gateway_availability_zones == "single" ? 1 : length(var.vpc_config.availability_zones)
  domain = "vpc"
  tags = {
    # This is where the nat eip name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-eip-${var.vpc_config.availability_zones[count.index]}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "natgw" {
  count         = length(aws_eip.nat_eip)
  allocation_id = element(aws_eip.nat_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  tags = {
    # This is where the NATGW name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-nat-public${count.index + 1}-${var.vpc_config.availability_zones[count.index]}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}


# Create public route table (this implicitly creates a local route)
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
  # DO NOTE USE THIS: Terraform has an ongoing bug with the gateway_id and nat_gateway_id where it 
  # considers them both the same values which will cause permanent difference in terraform plan -> apply
  # we use aws_route block to create individual routes, but we no longer need to define a local route
  # because this automatically creates the local route
  # route = []
  tags = {
    # This is where the public route table name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-rtb-public"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Create public route table route for igw
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_association" {
  count          = length(var.vpc_config.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_rtb.id
}


# Create private route table (this implicitly creates a local route)
resource "aws_route_table" "private_rtb" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id
  # DO NOTE USE THIS: Terraform has an ongoing bug with the gateway_id and nat_gateway_id where it 
  # considers them both the same values which will cause permanent difference in terraform plan -> apply
  # we use aws_route block to create individual routes, but we no longer need to define a local route
  # because this automatically creates the local route
  # route = []
  tags = {
    # This is where the public route table name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-rtb-private${count.index + 1}-${var.vpc_config.availability_zones[count.index]}"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}

# Create private route table route for natgw
resource "aws_route" "natgw_route" {
  count                  = length(aws_route_table.private_rtb)
  route_table_id         = element(aws_route_table.private_rtb[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index % length(aws_nat_gateway.natgw))
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_association" {
  count          = length(aws_route_table.private_rtb)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = element(aws_route_table.private_rtb[*].id, count.index)
}

# Create a VPC endpoint for Amazon S3
resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id = aws_vpc.vpc.id

  service_name    = "com.amazonaws.${var.common.region}.s3"
  route_table_ids = aws_route_table.private_rtb[*].id # Associate with your private route tables

  tags = {
    # This is where the public route table name is defined
    Name             = "${var.common.project_name}-${var.common.environment}-vpce-s3"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}



resource "aws_vpc_endpoint" "execute_api" {
  vpc_id              = var.params.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = var.params.subnet_ids
  security_group_ids = var.params.security_group_ids

  tags = {
    Name             = "${var.common.project_name}-${var.common.environment}-vpce-execute-api"
    Environment      = var.common.environment
    Project          = var.common.project_name
    TerraformManaged = true
  }
}
