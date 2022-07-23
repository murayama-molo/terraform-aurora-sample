
variable "domain_name" {}
variable "domain_name_certificate_arn" {}

locals {
  domain_name                 = var.domain_name # trimsuffix(data.aws_route53_zone.this.name, ".")
  domain_name_certificate_arn = var.domain_name_certificate_arn
  subdomain                   = "complete-http"
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  domain_name                 = local.domain_name
  domain_name_certificate_arn = local.domain_name_certificate_arn

  # Routes and integrations
  integrations = {
    "GET /api/hello" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }

  tags = {
    Name = "http-apigateway"
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "my-lambda-${terraform.workspace}"
  description   = "My awesome lambda function"
  handler       = "main.hello"
  runtime       = "python3.8"

  source_path = "../back"

  tags = {
    Name = "my-lambda1"
  }

  publish = true

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}
