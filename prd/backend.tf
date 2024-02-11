terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }

  backend "s3" {
    bucket         = "easternlai-terraform-backend"
    key            = "backend.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "tf-backend"
    profile        = "portfolio-prd"
  }
}

provider "aws" {
  region  = local.region
  profile = "portfolio-prd"
}


