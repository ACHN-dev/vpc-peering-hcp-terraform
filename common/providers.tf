# ==============================================================================
# Shared / Common AWS Provider Configuration
# All workspaces reference this file via symlink
# ==============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "VPC-Peering-Assignment"
      ManagedBy   = "Terraform"
      Environment = "Lab"
    }
  }
}
