# ==============================================================================
# Workspace: peering-ws
# Cross-VPC Peering Connection & Peering Routing
# ==============================================================================

# ------------------------------------------------------------------------------
# Remote State from fe-network-ws and be-network-ws
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

data "terraform_remote_state" "be_network" {
  backend = "remote"

  config = {
    organization = "achn-testing"
    workspaces = {
      name = "be-network-ws"
    }
  }
}

# ------------------------------------------------------------------------------
# VPC Peering Connection & Options
# ------------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = data.terraform_remote_state.fe_network.outputs.vpc_id
  peer_vpc_id = data.terraform_remote_state.be_network.outputs.vpc_id
  auto_accept = true

  tags = {
    Name = "Peering connection"
    VPC  = "hc-frontend-vpc <-> hc-backend-vpc"
  }
}

resource "aws_vpc_peering_connection_options" "peering_options" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# ------------------------------------------------------------------------------
# Peering Routes
# ------------------------------------------------------------------------------
# Frontend Routes (into Frontend private route tables 02 & 03)
resource "aws_route" "fe_to_be_pri_sub02" {
  route_table_id            = data.terraform_remote_state.fe_network.outputs.private_rtb02_id
  destination_cidr_block    = data.terraform_remote_state.be_network.outputs.private_subnet_cidrs.subnet02
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "fe_to_be_pri_sub03" {
  route_table_id            = data.terraform_remote_state.fe_network.outputs.private_rtb03_id
  destination_cidr_block    = data.terraform_remote_state.be_network.outputs.private_subnet_cidrs.subnet03
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

# Backend Routes (into Backend private route tables 02 & 03)
resource "aws_route" "be_to_fe_pri_sub02" {
  route_table_id            = data.terraform_remote_state.be_network.outputs.private_rtb02_id
  destination_cidr_block    = data.terraform_remote_state.fe_network.outputs.private_subnet_cidrs.subnet02
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "be_to_fe_pri_sub03" {
  route_table_id            = data.terraform_remote_state.be_network.outputs.private_rtb03_id
  destination_cidr_block    = data.terraform_remote_state.fe_network.outputs.private_subnet_cidrs.subnet03
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
