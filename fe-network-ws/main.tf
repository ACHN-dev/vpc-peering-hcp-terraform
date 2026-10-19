# ==============================================================================
# Workspace: fe-network-ws
# Frontend VPC, Subnets, Gateways & Route Tables
# ==============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# Frontend VPC (10.0.0.0/16)
# ------------------------------------------------------------------------------
resource "aws_vpc" "frontend" {
  cidr_block           = var.frontend_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hc-frontend-vpc"
  }
}

# Frontend Public Subnets
resource "aws_subnet" "fe_pub_subnet01" {
  vpc_id                  = aws_vpc.frontend.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet1"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_subnet" "fe_pub_subnet02" {
  vpc_id                  = aws_vpc.frontend.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet2"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_subnet" "fe_pub_subnet03" {
  vpc_id                  = aws_vpc.frontend.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet3"
    VPC  = "hc-frontend-vpc"
  }
}

# Frontend Private Subnets
resource "aws_subnet" "fe_pri_subnet01" {
  vpc_id            = aws_vpc.frontend.id
  cidr_block        = "10.0.253.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "pri-subnet1"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_subnet" "fe_pri_subnet02" {
  vpc_id            = aws_vpc.frontend.id
  cidr_block        = "10.0.254.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "pri-subnet2"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_subnet" "fe_pri_subnet03" {
  vpc_id            = aws_vpc.frontend.id
  cidr_block        = "10.0.255.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "pri-subnet3"
    VPC  = "hc-frontend-vpc"
  }
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "frontend" {
  vpc_id = aws_vpc.frontend.id

  tags = {
    Name = "Internet gateway"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_eip" "frontend_nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.frontend]

  tags = {
    Name = "fe-nat-eip"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_nat_gateway" "frontend" {
  allocation_id = aws_eip.frontend_nat.id
  subnet_id     = aws_subnet.fe_pub_subnet01.id
  depends_on    = [aws_internet_gateway.frontend]

  tags = {
    Name = "NAT gateway"
    VPC  = "hc-frontend-vpc"
  }
}

# ------------------------------------------------------------------------------
# Route Tables & Associations
# ------------------------------------------------------------------------------
resource "aws_route_table" "fe_public_rtb" {
  vpc_id = aws_vpc.frontend.id

  tags = {
    Name = "public rtb"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_route" "fe_public_internet" {
  route_table_id         = aws_route_table.fe_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.frontend.id
}

resource "aws_route_table_association" "fe_pub_sub01_assoc" {
  subnet_id      = aws_subnet.fe_pub_subnet01.id
  route_table_id = aws_route_table.fe_public_rtb.id
}

resource "aws_route_table_association" "fe_pub_sub02_assoc" {
  subnet_id      = aws_subnet.fe_pub_subnet02.id
  route_table_id = aws_route_table.fe_public_rtb.id
}

resource "aws_route_table_association" "fe_pub_sub03_assoc" {
  subnet_id      = aws_subnet.fe_pub_subnet03.id
  route_table_id = aws_route_table.fe_public_rtb.id
}

resource "aws_route_table" "fe_private_rtb01" {
  vpc_id = aws_vpc.frontend.id

  tags = {
    Name = "private-rtb-01"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_route" "fe_private_nat" {
  route_table_id         = aws_route_table.fe_private_rtb01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.frontend.id
}

resource "aws_route_table_association" "fe_pri_sub01_assoc" {
  subnet_id      = aws_subnet.fe_pri_subnet01.id
  route_table_id = aws_route_table.fe_private_rtb01.id
}

resource "aws_route_table" "fe_private_rtb02" {
  vpc_id = aws_vpc.frontend.id

  tags = {
    Name = "private-rtb-02"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_route_table_association" "fe_pri_sub02_assoc" {
  subnet_id      = aws_subnet.fe_pri_subnet02.id
  route_table_id = aws_route_table.fe_private_rtb02.id
}

resource "aws_route_table" "fe_private_rtb03" {
  vpc_id = aws_vpc.frontend.id

  tags = {
    Name = "private-rtb-03"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_route_table_association" "fe_pri_sub03_assoc" {
  subnet_id      = aws_subnet.fe_pri_subnet03.id
  route_table_id = aws_route_table.fe_private_rtb03.id
}
