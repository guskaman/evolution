provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "evo-tf-state"
    key    = "statefile/"
    region = "eu-west-1"
  }
}

################# BUILD #################

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "EVO VPC"
  }
}

resource "aws_iam_role" "k8s" {
  name = "EVO-k8s"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8s.name
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8s.name
}