terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "tf_lambda_bucket" {
  bucket = "tf-lambda-bucket"
}

module "gateway" {
  source = "./apigateway"
  integrations = [{
    arn   = module.my_fun.arn
    route = "/echo"
  }]
}

module "exec_role" {
  source = "./lambda-iam"
}


module "my_fun" {
  source        = "./lambda"
  bucket-name   = aws_s3_bucket.tf_lambda_bucket.id
  function-name = "tf-function"
  role-arn      = module.exec_role.role.arn
  code-path     = "../code"
  source-arn    = "${module.gateway.execution-arn}/*/*"
}