terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

data "archive_file" "blob" {
  type = "zip"
  output_path = "${path.module}/${var.function-name}"
  source_dir = var.code-path
}

resource "aws_s3_object" "s3_blob" {
  bucket = var.bucket-name
  key = "${var.function-name}.zip"
  source = data.archive_file.blob.output_path
  etag = filemd5(data.archive_file.blob.output_path)
}

resource "aws_lambda_function" "fun" {
  function_name = var.function-name
  s3_bucket = aws_s3_object.s3_blob.bucket
  s3_key = aws_s3_object.s3_blob.key
  source_code_hash = data.archive_file.blob.output_base64sha256

  runtime = "python3.9"
  handler = "function.handler"
  role = var.role-arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/${aws_lambda_function.fun.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "execution_perm" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fun.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = var.source-arn
}