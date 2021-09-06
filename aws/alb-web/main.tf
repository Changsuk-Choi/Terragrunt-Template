terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = var.terraform_state_bucket
    key     = var.terraform_network_path
    region  = var.aws_region
    profile = var.aws_profile    
  }
}
