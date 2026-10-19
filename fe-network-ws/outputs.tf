output "vpc_id" {
  description = "Frontend VPC ID"
  value       = aws_vpc.frontend.id
}

output "vpc_cidr" {
  description = "Frontend VPC CIDR block"
  value       = aws_vpc.frontend.cidr_block
}

output "public_subnets" {
  description = "Frontend Public Subnet IDs"
  value = {
    subnet01 = aws_subnet.fe_pub_subnet01.id
    subnet02 = aws_subnet.fe_pub_subnet02.id
    subnet03 = aws_subnet.fe_pub_subnet03.id
  }
}

output "private_subnets" {
  description = "Frontend Private Subnet IDs"
  value = {
    subnet01 = aws_subnet.fe_pri_subnet01.id
    subnet02 = aws_subnet.fe_pri_subnet02.id
    subnet03 = aws_subnet.fe_pri_subnet03.id
  }
}

output "private_subnet_cidrs" {
  description = "Frontend Private Subnet CIDRs"
  value = {
    subnet01 = aws_subnet.fe_pri_subnet01.cidr_block
    subnet02 = aws_subnet.fe_pri_subnet02.cidr_block
    subnet03 = aws_subnet.fe_pri_subnet03.cidr_block
  }
}

output "private_rtb02_id" {
  description = "Frontend Private Route Table 02 ID"
  value       = aws_route_table.fe_private_rtb02.id
}

output "private_rtb03_id" {
  description = "Frontend Private Route Table 03 ID"
  value       = aws_route_table.fe_private_rtb03.id
}
