terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

  }

  backend "s3" {
    bucket         = "easternlai-terraform-backend"
    key            = "backend.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "tf-backend"
    profile        = "portfolio-stg"
  }
}

provider "aws" {
  region  = local.region
  profile = "portfolio-stg"
}
