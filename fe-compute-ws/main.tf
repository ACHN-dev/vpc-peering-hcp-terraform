# ==============================================================================
# Workspace: fe-compute-ws
# Frontend EC2 Instances & Key Pair
# ==============================================================================

# ------------------------------------------------------------------------------
# Remote State from fe-network-ws and fe-security-ws
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
# AMI Data Sources
# ------------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# SSH Key Pair
# ------------------------------------------------------------------------------
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "fe-vpc-peering-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/fe-key.pem"
  file_permission = "0400"
}

# Store Private Key in AWS SSM Parameter Store for VCS runners
resource "aws_ssm_parameter" "fe_private_key" {
  name        = "/vpc-peering/fe/private_key_pem"
  description = "Frontend Private SSH Key for VPC Peering instances (Managed by VCS)"
  type        = "SecureString"
  value       = tls_private_key.ssh_key.private_key_pem

  tags = {
    Name = "fe-vpc-peering-key"
  }
}

# ------------------------------------------------------------------------------
# Frontend EC2 Instances
# ------------------------------------------------------------------------------
# Public Instance 01 (Bastion)
resource "aws_instance" "fe_public_instance01" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.fe_network.outputs.public_subnets.subnet01
  vpc_security_group_ids      = [data.terraform_remote_state.fe_security.outputs.security_groups.pub_sg01]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name

  tags = {
    Name = "public-instance-01"
    VPC  = "hc-frontend-vpc"
    Tier = "Public"
  }
}

# Private Instance 01
resource "aws_instance" "fe_private_instance01" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.fe_network.outputs.private_subnets.subnet01
  vpc_security_group_ids      = [data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg01]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.main.key_name

  tags = {
    Name = "private-instance-01"
    VPC  = "hc-frontend-vpc"
    Tier = "Private"
  }
}

# Private Instance 02
resource "aws_instance" "fe_private_instance02" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.fe_network.outputs.private_subnets.subnet02
  vpc_security_group_ids      = [data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg02]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.main.key_name

  tags = {
    Name = "private-instance-02"
    VPC  = "hc-frontend-vpc"
    Tier = "Private"
  }
}

# Private Instance 03
resource "aws_instance" "fe_private_instance03" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.fe_network.outputs.private_subnets.subnet03
  vpc_security_group_ids      = [data.terraform_remote_state.fe_security.outputs.security_groups.pri_sg03]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.main.key_name

  tags = {
    Name = "private-instance-03"
    VPC  = "hc-frontend-vpc"
    Tier = "Private"
  }
}
