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


#network
resource "aws_vpc" "main" {
  cidr_block       = "192.168.88.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "EVO"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.vpc_id
  cidr_block = "192.168.88.0/26"

  tags = {
    Name = "K8S"
  }
}

resource "aws_vpc" "allow_all" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

#permissions
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

#cluster
