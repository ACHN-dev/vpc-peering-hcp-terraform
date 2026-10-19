# ==============================================================================
# Workspace: fe-security-ws
# Frontend Security Groups & Internal Rules
# ==============================================================================

# ------------------------------------------------------------------------------
# Remote State from fe-network-ws
# ------------------------------------------------------------------------------
data "terraform_remote_state" "fe_network" {
  backend = "remote"

  config = {
    organization = "achn-testing"
    workspaces = {
      name = "fe-network-ws"
    }
  }
}

# ------------------------------------------------------------------------------
# Security Group Definitions
# ------------------------------------------------------------------------------
resource "aws_security_group" "fe_pub_sg01" {
  name        = "pub-sgp-01"
  description = "Public SG for hc-frontend-vpc public-instance-01"
  vpc_id      = data.terraform_remote_state.fe_network.outputs.vpc_id

  tags = {
    Name   = "pub-sgp-01"
    VPC    = "hc-frontend-vpc"
    Status = "Active"
  }
}

resource "aws_security_group" "fe_pri_sg01" {
  name        = "pri-sgp-01"
  description = "Private SG for hc-frontend-vpc private-instance-01"
  vpc_id      = data.terraform_remote_state.fe_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-01"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_security_group" "fe_pri_sg02" {
  name        = "pri-sgp-02"
  description = "Private SG for hc-frontend-vpc private-instance-02"
  vpc_id      = data.terraform_remote_state.fe_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-02"
    VPC  = "hc-frontend-vpc"
  }
}

resource "aws_security_group" "fe_pri_sg03" {
  name        = "pri-sgp-03"
  description = "Private SG for hc-frontend-vpc private-instance-03"
  vpc_id      = data.terraform_remote_state.fe_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-03"
    VPC  = "hc-frontend-vpc"
  }
}

# ------------------------------------------------------------------------------
# 1. fe_pub_sg01 Rules
# ------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "fe_pub_sg01_ping" {
  security_group_id = aws_security_group.fe_pub_sg01.id
  cidr_ipv4         = var.my_ip
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  description       = "Allow Only Your IP to ping to public-instance-01(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pub_sg01_ssh" {
  security_group_id = aws_security_group.fe_pub_sg01.id
  cidr_ipv4         = var.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Allow Only Your IP to SSH to public-instance-01(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pub_sg01_egress_all" {
  security_group_id = aws_security_group.fe_pub_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow ALL Types of traffic to destination 0.0.0.0/0"
}

# ------------------------------------------------------------------------------
# 2. fe_pri_sg01 Rules
# ------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg01_ping_from_pub" {
  security_group_id            = aws_security_group.fe_pri_sg01.id
  referenced_security_group_id = aws_security_group.fe_pub_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only pub-sgp-01 to ping to private-instance-01(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg01_ssh_from_pub" {
  security_group_id            = aws_security_group.fe_pri_sg01.id
  referenced_security_group_id = aws_security_group.fe_pub_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only pub-sgp-01 to SSH to private-instance-01(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pri_sg01_egress_all" {
  security_group_id = aws_security_group.fe_pri_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow ALL Types of traffic to destination 0.0.0.0/0"
}

# ------------------------------------------------------------------------------
# 3. fe_pri_sg02 Rules (FE Internal)
# ------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg02_ping_from_fe_pri01" {
  security_group_id            = aws_security_group.fe_pri_sg02.id
  referenced_security_group_id = aws_security_group.fe_pri_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-01(hc-frontend-vpc) to ping TO private-instance-02(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg02_ssh_from_fe_pri01" {
  security_group_id            = aws_security_group.fe_pri_sg02.id
  referenced_security_group_id = aws_security_group.fe_pri_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-01(hc-frontend-vpc) to SSH TO private-instance-02(hc-frontend-vpc)"
}

# ------------------------------------------------------------------------------
# 4. fe_pri_sg03 Rules (FE Internal)
# ------------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg03_ping_from_fe_pri01" {
  security_group_id            = aws_security_group.fe_pri_sg03.id
  referenced_security_group_id = aws_security_group.fe_pri_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-01(hc-frontend-vpc) to ping TO private-instance-03(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg03_ssh_from_fe_pri01" {
  security_group_id            = aws_security_group.fe_pri_sg03.id
  referenced_security_group_id = aws_security_group.fe_pri_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-01(hc-frontend-vpc) to SSH TO private-instance-03(hc-frontend-vpc)"
}
