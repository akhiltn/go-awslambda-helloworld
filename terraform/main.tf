// build the binary for the lambda function in a specified path
locals {
  app-name     = "aws-lambda-helloworld"
  binary_name  = "bootstrap"
  archive_path = "dist/${local.app-name}.zip"
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "lambda_invoke_policy"
  description = "Policy to allow API Gateway to invoke Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = module.lambda_function.lambda_function_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_invoke_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.7.1"

  function_name          = "app-${local.app-name}"
  handler                = local.binary_name
  runtime                = "provided.al2023"
  create_package         = false
  local_existing_package = local.archive_path
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "5.1.0"

  name               = "api-${local.app-name}"
  protocol_type      = "HTTP"
  create_domain_name = false # Disable Route 53 configuration

  routes = {
    "ANY /helloworld" = {
      integration = {
        uri                    = module.lambda_function.lambda_function_arn
        payload_format_version = "2.0"
        credentials_arn        = aws_iam_role.api_gateway_role.arn
      }
    }
  }
}
