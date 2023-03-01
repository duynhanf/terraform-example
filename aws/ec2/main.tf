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

# Create an instance
resource "aws_instance" "my-instance" {
  ami           = "ami-0b828c1c5ac3f13ee"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  key_name                    = "nhan.dev-kp"

  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo service nginx start
sudo sh -c "echo 'Hello, Terraform!' > /var/www/html/index.html"

EOF

  tags = {
    Name = "my-instance"
  }
}
