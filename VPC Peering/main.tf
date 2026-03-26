# Standard Production Provider Block
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Using the latest stable 5.x version
    }
  }
}

provider "aws" {
  region = var.region
  
  # Default tags apply to EVERY resource in this project automatically
  default_tags {
    tags = {
      Project     = "VPC-Peering-Project-Part-A"
      Environment = "Production"
      Owner       = "Satya"
      ManagedBy   = "Terraform"
    }
  }
}