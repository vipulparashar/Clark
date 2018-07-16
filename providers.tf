provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
