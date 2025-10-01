terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = "ap-southeast-2"
}

# access
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKkAX0+yqK1s2jAhDy+uTrhFH5VZ59/eqHhlPhlhxYeU tkl@tkl-pc"
}

# vpcing and subnetting
resource "aws_vpc" "terprovd-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-prov-vpc"
  }
}
resource "aws_subnet" "terprovd-pub1-subnet" {
  availability_zone       = "ap-southeast-2a"
  vpc_id                  = aws_vpc.terprovd-vpc.id
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terprovd-public1-subnet"
  }
}
resource "aws_subnet" "terprovd-prv1-subnet" {
  availability_zone = "ap-southeast-2a"
  vpc_id            = aws_vpc.terprovd-vpc.id
  cidr_block        = "10.0.101.0/24"

  tags = {
    Name = "terprovd-private1-subnet"
  }
}
resource "aws_subnet" "terproved-prv3-subnet" {
  availability_zone = "ap-southeast-2a"
  vpc_id            = aws_vpc.terprovd-vpc.id
  cidr_block        = "10.0.103.0/24"

  tags = {
    Name = "terprovd-private1-subnet"
  }
}
