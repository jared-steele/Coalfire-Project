data "aws_availability_zones" "az" { state = "available" }

locals {
  az_a = data.aws_availability_zones.az.names[0]
  az_b = data.aws_availability_zones.az.names[1]
}

# VPC: private network boundary with DNS enabled
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "cf-vpc" })
}

# Subnets: mgmt(public), app(private), backend(private) across 2 AZs
resource "aws_subnet" "mgmt" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.mgmt_cidr
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "cf-mgmt-public" })
}
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_cidr
  availability_zone = local.az_b
  tags = merge(var.tags, { Name = "cf-app-private" })
}
resource "aws_subnet" "backend" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.backend_cidr
  availability_zone = local.az_a
  tags = merge(var.tags, { Name = "cf-backend-private" })
}

# IGW: public internet access for mgmt subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "cf-igw" })
}

# NAT GW: private egress for app/backend (cheap/simple; note single-AZ tradeoff)
resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.mgmt.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = "cf-nat" })
}

# Routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "cf-public-rt" })
}
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "mgmt_assoc" {
  subnet_id      = aws_subnet.mgmt.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "cf-private-rt" })
}
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "backend_assoc" {
  subnet_id      = aws_subnet.backend.id
  route_table_id = aws_route_table.private.id
}
