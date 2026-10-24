output "peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.peering.id
}

output "peering_status" {
  description = "VPC Peering Connection Status"
  value       = aws_vpc_peering_connection.peering.accept_status
}
