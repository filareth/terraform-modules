#----------------------------------------------------------
# My Terraform
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give access to Internet from Private Subnets
#
#  CIDR blocks of different environments must be of the same type, 
#  for example: "10.10.0.0/16", "10.40.0.0/16", "10.100.0.0/16"  
#
# Made by Vladyslav Kovalenko. Summer 2024
#----------------------------------------------------------

data "aws_availability_zones" "available" {}

resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-env"
  }
}

resource "aws_internet_gateway" "dev-IGW" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${var.env}-IGW"
  }
}

# ----------- create public subnets and routes --------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_routes" {
  count  = max(length(var.public_subnet_cidrs), var.az_count)
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-IGW.id
  }
  tags = {
    Name = "${var.env}-route-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.public_routes[count.index].id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

# ----------- create private subnets and routes --------------------------------------
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "${var.env}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "private_routes" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.private_routes[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

#-----NAT Gateways with Elastic IPs--------------------------
resource "aws_eip" "nat" {
  count   = length(var.private_subnet_cidrs)
  domain  = "vpc"
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}
