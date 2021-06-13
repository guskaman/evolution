provider "aws" {
  region = "eu-west-1"
  # access_key = "$AWS_ACCESS_KEY_ID"
  # secret_key = "$AWS_SECRET_ACCESS_KEY"
}

terraform {
  backend "s3" {
    bucket = "evo-tf-state"
    key    = "statefile/"
    region = "eu-west-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "EVO VPC"
  }
}