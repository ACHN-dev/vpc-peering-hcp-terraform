terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "achn-testing"

    workspaces {
      name = "fe-security-ws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
