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

module "website_s3_bucket" {
  source = "./modules/s3-static-website-bucket"

  bucket_name = "nhan.dev-bucket"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
