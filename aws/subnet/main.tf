terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

# Create a private subnet
resource "aws_subnet" "my_vpc_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "my_vpc_private_subnet"
  }
}

# Create a public subnet
resource "aws_subnet" "my_vpc_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "my_vpc_public_subnet"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id # Attach to my_vpc

  tags = {
    Name = "my_vpc_igw"
  }
}

resource "aws_route_table" "my_vpc_public_subnet_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "my_vpc_public_subnet_rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.my_vpc_public_subnet.id
  route_table_id = aws_route_table.my_vpc_public_subnet_rt.id
}

resource "aws_route_table" "my_vpc_private_subnet_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route = []

  tags = {
    Name = "my_vpc_private_subnet_rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.my_vpc_private_subnet.id
  route_table_id = aws_route_table.my_vpc_private_subnet_rt.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_vpc.my_vpc.default_security_group_id

  description = "SSH to VPC"
  from_port   = 22
  to_port     = 22
  ip_protocol = "TCP"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_vpc.my_vpc.default_security_group_id

  description = "HTTP support"
  from_port   = 80
  to_port     = 80
  ip_protocol = "TCP"
  cidr_ipv4   = "0.0.0.0/0"
}

# Create an instance
resource "aws_instance" "my_vpc_public_subnet_instance_1" {
  ami           = "ami-0b828c1c5ac3f13ee"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.my_vpc_public_subnet.id
  associate_public_ip_address = true
  key_name                    = "nhan.dev-kp"

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo service nginx start

EOF

  tags = {
    Name = "my_vpc_public_subnet_instance_1"
  }
}
