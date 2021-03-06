terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-09439f09c55136ecf"
  instance_type = "t2.micro"

  tags = {
    Name = "TFExampleServer"
  }
}