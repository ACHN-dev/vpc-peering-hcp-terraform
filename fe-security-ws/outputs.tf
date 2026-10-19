output "security_groups" {
  description = "Frontend Security Group IDs"
  value = {
    pub_sg01 = aws_security_group.fe_pub_sg01.id
    pri_sg01 = aws_security_group.fe_pri_sg01.id
    pri_sg02 = aws_security_group.fe_pri_sg02.id
    pri_sg03 = aws_security_group.fe_pri_sg03.id
  }
}
