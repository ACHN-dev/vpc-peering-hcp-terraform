output "public_instance_ip" {
  description = "Backend Public Instance (Bastion) Public IP"
  value       = aws_instance.be_public_instance01.public_ip
}

output "private_instance_ips" {
  description = "Backend Private Instances IPs"
  value = {
    private_instance_01 = aws_instance.be_private_instance01.private_ip
    private_instance_02 = aws_instance.be_private_instance02.private_ip
    private_instance_03 = aws_instance.be_private_instance03.private_ip
  }
}

output "ssh_commands" {
  description = "SSH Commands for Backend"
  value = {
    ssh_bastion = "ssh -i be-key.pem ec2-user@${aws_instance.be_public_instance01.public_ip}"
    ssh_pri01   = "ssh -i be-key.pem -J ec2-user@${aws_instance.be_public_instance01.public_ip} ubuntu@${aws_instance.be_private_instance01.private_ip}"
    ssh_pri02   = "ssh -i be-key.pem -J ec2-user@${aws_instance.be_public_instance01.public_ip} ubuntu@${aws_instance.be_private_instance02.private_ip}"
    ssh_pri03   = "ssh -i be-key.pem -J ec2-user@${aws_instance.be_public_instance01.public_ip} ubuntu@${aws_instance.be_private_instance03.private_ip}"
  }
}

output "private_key_pem" {
  description = "SSH Private Key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
