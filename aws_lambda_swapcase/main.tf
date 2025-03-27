terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/7.17.0
# https://github.com/terraform-aws-modules/terraform-aws-lambda

module "lambda_function" {
  source 		= "terraform-aws-modules/lambda/aws"
  function_name = "SwApCaSe"
  description   = "Swap text case function"
  handler       = "lambda_swapcase.lambda_handler"
  runtime       = "python3.12"
  source_path   = "src/lambda_swapcase.py"
  create_lambda_function_url = true
}

output "function_name" {
	value = module.lambda_function.lambda_function_name
}

output "function_url" {
	value = module.lambda_function.lambda_function_url
}
