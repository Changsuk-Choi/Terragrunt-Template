terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "archive" {}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket  = var.terraform_state_bucket
    key     = var.terraform_iam_path
    region  = var.aws_region
    profile = var.aws_profile
  }
}
