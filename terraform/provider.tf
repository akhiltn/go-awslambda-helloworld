terraform {
  cloud {
    organization = "akhil-terraform-org"

    workspaces {
      name = "go-awslambda-helloworld"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "ap-south-1"
  # profile = "default"
}

