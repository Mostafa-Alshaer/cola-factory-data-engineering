provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "cola-factory-data-team-deployment"
    workspace_key_prefix = "tf-state"
    key = "terraform.tfstate"
  }
 }