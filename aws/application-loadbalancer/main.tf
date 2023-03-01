terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Query default vpc, subnets, security groups
data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "selected" {
  name   = "default"
  vpc_id = data.aws_vpc.selected.id
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

# Create an instance
resource "aws_instance" "i-frontend-1" {
  ami           = "ami-0b828c1c5ac3f13ee"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  key_name                    = "nhan.dev-kp"

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo service nginx start
sudo sh -c "echo 'Hello from instance 1' > /var/www/html/index.html"

EOF

  tags = {
    Name = "i-frontend-1"
  }
}

resource "aws_instance" "i-frontend-2" {
  ami           = "ami-0b828c1c5ac3f13ee"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  key_name                    = "nhan.dev-kp"

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo service nginx start
sudo sh -c "echo 'Hello from instance 2' > /var/www/html/index.html"

EOF

  tags = {
    Name = "i-frontend-2"
  }
}

# Create application load balancer for 2 instances
resource "aws_lb" "lb-frontend" {
  name               = "lb-frontend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.selected.id]
  subnets            = [for id in data.aws_subnets.selected.ids : id]

  tags = {
    Environment = "some thing"
  }
}

resource "aws_lb_target_group" "lg-tg-frontend" {
  name     = "lg-tg-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
}

resource "aws_lb_listener" "lb-listener-frontend" {
  load_balancer_arn = aws_lb.lb-frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lg-tg-frontend.arn
  }
}

resource "aws_lb_target_group_attachment" "lb-tg-a-1" {
  target_group_arn = aws_lb_target_group.lg-tg-frontend.arn
  target_id        = aws_instance.i-frontend-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "lb-tg-a-2" {
  target_group_arn = aws_lb_target_group.lg-tg-frontend.arn
  target_id        = aws_instance.i-frontend-2.id
  port             = 80
}

