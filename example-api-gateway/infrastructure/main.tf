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
  integrations = [
    {
      arn   = module.hello_lambda.arn
      route = "/hello"
    },
    {
      arn   = module.goodbye_lambda.arn
      route = "/goodbye"
    }
  ]
}

module "exec_role" {
  source = "./lambda-iam"
}


module "hello_lambda" {
  source        = "./lambda"
  bucket-name   = aws_s3_bucket.tf_lambda_bucket.id
  function-name = "tf-hello"
  role-arn      = module.exec_role.role.arn
  code-path     = "../code/hello"
  source-arn    = "${module.gateway.execution-arn}/*/*"
}

module "goodbye_lambda" {
  source        = "./lambda"
  bucket-name   = aws_s3_bucket.tf_lambda_bucket.id
  function-name = "tf-goodbye"
  role-arn      = module.exec_role.role.arn
  code-path     = "../code/goodbye"
  source-arn    = "${module.gateway.execution-arn}/*/*"
}