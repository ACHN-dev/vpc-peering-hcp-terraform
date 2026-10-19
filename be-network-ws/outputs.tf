output "vpc_id" {
  description = "Backend VPC ID"
  value       = aws_vpc.backend.id
}

output "vpc_cidr" {
  description = "Backend VPC CIDR block"
  value       = aws_vpc.backend.cidr_block
}

output "public_subnets" {
  description = "Backend Public Subnet IDs"
  value = {
    subnet01 = aws_subnet.be_pub_subnet01.id
    subnet02 = aws_subnet.be_pub_subnet02.id
    subnet03 = aws_subnet.be_pub_subnet03.id
  }
}

output "private_subnets" {
  description = "Backend Private Subnet IDs"
  value = {
    subnet01 = aws_subnet.be_pri_subnet01.id
    subnet02 = aws_subnet.be_pri_subnet02.id
    subnet03 = aws_subnet.be_pri_subnet03.id
  }
}

output "private_subnet_cidrs" {
  description = "Backend Private Subnet CIDRs"
  value = {
    subnet01 = aws_subnet.be_pri_subnet01.cidr_block
    subnet02 = aws_subnet.be_pri_subnet02.cidr_block
    subnet03 = aws_subnet.be_pri_subnet03.cidr_block
  }
}

output "peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.peering.id
}
