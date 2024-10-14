terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
    # bucket, key and region set via cli or worflow
  }

  required_providers {
    aws = {
      #version = ">= 5.31.0"
    }
  }
}
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = var.tags
  }
}