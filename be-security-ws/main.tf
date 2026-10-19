# ==============================================================================
# Workspace: be-security-ws
# Backend Security Groups, Internal Rules & Cross-Peering Security Rules
# ==============================================================================

# ------------------------------------------------------------------------------
# Remote State from be-network-ws and fe-security-ws
# ------------------------------------------------------------------------------
data "terraform_remote_state" "be_network" {
  backend = "remote"

  config = {
    organization = "achn-testing"
    workspaces = {
      name = "be-network-ws"
    }
  }
}

data "terraform_remote_state" "fe_security" {
  backend = "remote"

  config = {
    organization = "achn-testing"
    workspaces = {
      name = "fe-security-ws"
    }
  }
}

# ------------------------------------------------------------------------------
# Backend Security Group Definitions
# ------------------------------------------------------------------------------
resource "aws_security_group" "be_pub_sg01" {
  name        = "pub-sgp-01"
  description = "Public SG for hc-backend-vpc public-instance-01"
  vpc_id      = data.terraform_remote_state.be_network.outputs.vpc_id

  tags = {
    Name = "pub-sgp-01"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_security_group" "be_pri_sg01" {
  name        = "pri-sgp-01"
  description = "Private SG for hc-backend-vpc private-instance-01"
  vpc_id      = data.terraform_remote_state.be_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-01"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_security_group" "be_pri_sg02" {
  name        = "pri-sgp-02"
  description = "Private SG for hc-backend-vpc private-instance-02"
  vpc_id      = data.terraform_remote_state.be_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-02"
    VPC  = "hc-backend-vpc"
  }
}

resource "aws_security_group" "be_pri_sg03" {
  name        = "pri-sgp-03"
  description = "Private SG for hc-backend-vpc private-instance-03"
  vpc_id      = data.terraform_remote_state.be_network.outputs.vpc_id

  tags = {
    Name = "pri-sgp-03"
    VPC  = "hc-backend-vpc"
  }
}

# ------------------------------------------------------------------------------
# Backend Internal Rules
# ------------------------------------------------------------------------------
# be_pub_sg01
resource "aws_vpc_security_group_ingress_rule" "be_pub_sg01_ping" {
  security_group_id = aws_security_group.be_pub_sg01.id
  cidr_ipv4         = var.my_ip
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  description       = "Allow Only Your IP to ping to public-instance-01(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pub_sg01_ssh" {
  security_group_id = aws_security_group.be_pub_sg01.id
  cidr_ipv4         = var.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Allow Only Your IP to SSH to public-instance-01(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pub_sg01_egress_all" {
  security_group_id = aws_security_group.be_pub_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow ALL Types of traffic to destination 0.0.0.0/0"
}

# be_pri_sg01
resource "aws_vpc_security_group_ingress_rule" "be_pri_sg01_ping_from_pub" {
  security_group_id            = aws_security_group.be_pri_sg01.id
  referenced_security_group_id = aws_security_group.be_pub_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only pub-sgp-01 to ping to private-instance-01(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pri_sg01_ssh_from_pub" {
  security_group_id            = aws_security_group.be_pri_sg01.id
  referenced_security_group_id = aws_security_group.be_pub_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only pub-sgp-01 to SSH to private-instance-01(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pri_sg01_egress_all" {
  security_group_id = aws_security_group.be_pri_sg01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow ALL Types of traffic to destination 0.0.0.0/0"
}

# be_pri_sg02 internal
resource "aws_vpc_security_group_ingress_rule" "be_pri_sg02_ping_from_be_pri01" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = aws_security_group.be_pri_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-01(hc-backend-vpc) to ping TO private-instance-02(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pri_sg02_ssh_from_be_pri01" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = aws_security_group.be_pri_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-01(hc-backend-vpc) to SSH TO private-instance-02(hc-backend-vpc)"
}

# be_pri_sg03 internal
resource "aws_vpc_security_group_ingress_rule" "be_pri_sg03_ping_from_be_pri01" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = aws_security_group.be_pri_sg01.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-01(hc-backend-vpc) to ping TO private-instance-03(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pri_sg03_ssh_from_be_pri01" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = aws_security_group.be_pri_sg01.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-01(hc-backend-vpc) to SSH TO private-instance-03(hc-backend-vpc)"
}

# ------------------------------------------------------------------------------
# Cross-Peering Rules: pri-sgp-02 <-> pri-sgp-02
# ------------------------------------------------------------------------------
# Frontend pri-sgp-02 ingress/egress
resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg02_ping_from_be_pri02" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  referenced_security_group_id = aws_security_group.be_pri_sg02.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-02(hc-backend-vpc) to ping TO private-instance-02(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg02_ssh_from_be_pri02" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  referenced_security_group_id = aws_security_group.be_pri_sg02.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-02(hc-backend-vpc) to SSH TO private-instance-02(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pri_sg02_ping_to_be_pri02" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  referenced_security_group_id = aws_security_group.be_pri_sg02.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only to ping TO private-instance-02(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pri_sg02_ssh_to_be_pri02" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  referenced_security_group_id = aws_security_group.be_pri_sg02.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only to SSH TO private-instance-02(hc-backend-vpc)"
}

# Backend pri-sgp-02 ingress/egress
resource "aws_vpc_security_group_ingress_rule" "be_pri_sg02_ping_from_fe_pri02" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-02(hc-frontend-vpc) to ping TO private-instance-02(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pri_sg02_ssh_from_fe_pri02" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-02(hc-frontend-vpc) to SSH TO private-instance-02(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pri_sg02_ping_to_fe_pri02" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only to ping TO private-instance-02(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pri_sg02_ssh_to_fe_pri02" {
  security_group_id            = aws_security_group.be_pri_sg02.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only to SSH TO private-instance-02(hc-frontend-vpc)"
}

# ------------------------------------------------------------------------------
# Cross-Peering Rules: pri-sgp-03 <-> pri-sgp-03
# ------------------------------------------------------------------------------
# Frontend pri-sgp-03 ingress/egress
resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg03_ping_from_be_pri03" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  referenced_security_group_id = aws_security_group.be_pri_sg03.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-03(hc-backend-vpc) to ping TO private-instance-03(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "fe_pri_sg03_ssh_from_be_pri03" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  referenced_security_group_id = aws_security_group.be_pri_sg03.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-03(hc-backend-vpc) to SSH TO private-instance-03(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pri_sg03_ping_to_be_pri03" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  referenced_security_group_id = aws_security_group.be_pri_sg03.id
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only to ping TO private-instance-03(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "fe_pri_sg03_ssh_to_be_pri03" {
  security_group_id            = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  referenced_security_group_id = aws_security_group.be_pri_sg03.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only to SSH TO private-instance-03(hc-backend-vpc)"
}

# Backend pri-sgp-03 ingress/egress
resource "aws_vpc_security_group_ingress_rule" "be_pri_sg03_ping_from_fe_pri03" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only FROM pri-sgp-03(hc-frontend-vpc) to ping TO private-instance-03(hc-backend-vpc)"
}

resource "aws_vpc_security_group_ingress_rule" "be_pri_sg03_ssh_from_fe_pri03" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only FROM pri-sgp-03(hc-frontend-vpc) to SSH TO private-instance-03(hc-backend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pri_sg03_ping_to_fe_pri03" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  ip_protocol                  = "icmp"
  from_port                    = 8
  to_port                      = 0
  description                  = "Allow Only to ping TO private-instance-03(hc-frontend-vpc)"
}

resource "aws_vpc_security_group_egress_rule" "be_pri_sg03_ssh_to_fe_pri03" {
  security_group_id            = aws_security_group.be_pri_sg03.id
  referenced_security_group_id = data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow Only to SSH TO private-instance-03(hc-frontend-vpc)"
}
