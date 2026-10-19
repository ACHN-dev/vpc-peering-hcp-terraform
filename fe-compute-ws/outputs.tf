output "public_instance_ip" {
  description = "Frontend Public Instance (Bastion) Public IP"
  value       = aws_instance.fe_public_instance01.public_ip
}

output "private_instance_ips" {
  description = "Frontend Private Instances IPs"
  value = {
    private_instance_01 = aws_instance.fe_private_instance01.private_ip
    private_instance_02 = aws_instance.fe_private_instance02.private_ip
    private_instance_03 = aws_instance.fe_private_instance03.private_ip
  }
}

output "ssh_commands" {
  description = "SSH Commands for Frontend"
  value = {
    ssh_bastion = "ssh -i fe-key.pem ec2-user@${aws_instance.fe_public_instance01.public_ip}"
    ssh_pri01   = "ssh -i fe-key.pem -J ec2-user@${aws_instance.fe_public_instance01.public_ip} ubuntu@${aws_instance.fe_private_instance01.private_ip}"
    ssh_pri02   = "ssh -i fe-key.pem -J ec2-user@${aws_instance.fe_public_instance01.public_ip} ubuntu@${aws_instance.fe_private_instance02.private_ip}"
    ssh_pri03   = "ssh -i fe-key.pem -J ec2-user@${aws_instance.fe_public_instance01.public_ip} ubuntu@${aws_instance.fe_private_instance03.private_ip}"
  }
}

output "private_key_pem" {
  description = "SSH Private Key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
