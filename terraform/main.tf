// build the binary for the lambda function in a specified path
locals {
  app-name     = "aws-lambda-helloworld"
  binary_name  = "bootstrap"
  archive_path = "dist/${local.app-name}.zip"
}


// create the lambda function from zip file
resource "aws_lambda_function" "function" {
  function_name    = "app-${local.app-name}"
  description      = "My first hello world function"
  role             = aws_iam_role.lambda.arn
  handler          = local.binary_name
  memory_size      = 128
  filename         = local.archive_path
  source_code_hash = filebase64sha256(local.archive_path)

  runtime       = "provided.al2023"
  architectures = ["x86_64"]
}

// create log group in cloudwatch to gather logs of our lambda function
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = 3
}
