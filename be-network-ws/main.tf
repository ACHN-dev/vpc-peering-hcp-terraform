# ==============================================================================
# Workspace: be-network-ws
# Backend VPC, Subnets, Gateways & Route Tables
# ==============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# Backend VPC (192.168.0.0/16)
# ------------------------------------------------------------------------------
resource "aws_vpc" "backend" {
  cidr_block           = var.backend_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hc-backend-vpc"
  }
}

# Backend Public Subnets
resource "aws_subnet" "be_pub_subnet01" {
  vpc_id                  = aws_vpc.backend.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet1"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_subnet" "be_pub_subnet02" {
  vpc_id                  = aws_vpc.backend.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet2"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_subnet" "be_pub_subnet03" {
  vpc_id                  = aws_vpc.backend.id
  cidr_block              = "192.168.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet3"
    VPC  = "hc-backend-vpc"
  }
}

# Backend Private Subnets
resource "aws_subnet" "be_pri_subnet01" {
  vpc_id            = aws_vpc.backend.id
  cidr_block        = "192.168.253.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "pri-subnet1"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_subnet" "be_pri_subnet02" {
  vpc_id            = aws_vpc.backend.id
  cidr_block        = "192.168.254.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "pri-subnet2"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_subnet" "be_pri_subnet03" {
  vpc_id            = aws_vpc.backend.id
  cidr_block        = "192.168.255.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "pri-subnet3"
    VPC  = "hc-backend-vpc"
  }
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "backend" {
  vpc_id = aws_vpc.backend.id

  tags = {
    Name = "Internet gateway"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_eip" "backend_nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.backend]

  tags = {
    Name = "be-nat-eip"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_nat_gateway" "backend" {
  allocation_id = aws_eip.backend_nat.id
  subnet_id     = aws_subnet.be_pub_subnet01.id
  depends_on    = [aws_internet_gateway.backend]

  tags = {
    Name = "NAT gateway"
    VPC  = "hc-backend-vpc"
  }
}

# ------------------------------------------------------------------------------
# Route Tables & Associations
# ------------------------------------------------------------------------------
resource "aws_route_table" "be_public_rtb" {
  vpc_id = aws_vpc.backend.id

  tags = {
    Name = "public rtb"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_route" "be_public_internet" {
  route_table_id         = aws_route_table.be_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.backend.id
}

resource "aws_route_table_association" "be_pub_sub01_assoc" {
  subnet_id      = aws_subnet.be_pub_subnet01.id
  route_table_id = aws_route_table.be_public_rtb.id
}

resource "aws_route_table_association" "be_pub_sub02_assoc" {
  subnet_id      = aws_subnet.be_pub_subnet02.id
  route_table_id = aws_route_table.be_public_rtb.id
}

resource "aws_route_table_association" "be_pub_sub03_assoc" {
  subnet_id      = aws_subnet.be_pub_subnet03.id
  route_table_id = aws_route_table.be_public_rtb.id
}

resource "aws_route_table" "be_private_rtb01" {
  vpc_id = aws_vpc.backend.id

  tags = {
    Name = "private-rtb-01"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_route" "be_private_nat" {
  route_table_id         = aws_route_table.be_private_rtb01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.backend.id
}

resource "aws_route_table_association" "be_pri_sub01_assoc" {
  subnet_id      = aws_subnet.be_pri_subnet01.id
  route_table_id = aws_route_table.be_private_rtb01.id
}

resource "aws_route_table" "be_private_rtb02" {
  vpc_id = aws_vpc.backend.id

  tags = {
    Name = "private-rtb-02"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_route_table_association" "be_pri_sub02_assoc" {
  subnet_id      = aws_subnet.be_pri_subnet02.id
  route_table_id = aws_route_table.be_private_rtb02.id
}

resource "aws_route_table" "be_private_rtb03" {
  vpc_id = aws_vpc.backend.id

  tags = {
    Name = "private-rtb-03"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_route_table_association" "be_pri_sub03_assoc" {
  subnet_id      = aws_subnet.be_pri_subnet03.id
  route_table_id = aws_route_table.be_private_rtb03.id
}
