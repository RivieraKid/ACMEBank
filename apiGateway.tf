resource "aws_api_gateway_rest_api" "ACMEBankAPIGateway" {
  name        = var.apigateway_name
  description = "Bank account interest calculation API"
  endpoint_configuration {
      types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "InterestResource" {
  rest_api_id = aws_api_gateway_rest_api.ACMEBankAPIGateway.id
  parent_id   = aws_api_gateway_rest_api.ACMEBankAPIGateway.root_resource_id
  path_part   = "getinterest"
}

resource "aws_api_gateway_method" "GetInterestMethod" {
  rest_api_id   = aws_api_gateway_rest_api.ACMEBankAPIGateway.id
  resource_id   = aws_api_gateway_resource.InterestResource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "GetInterestLambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.ACMEBankAPIGateway.id
  resource_id             = aws_api_gateway_resource.InterestResource.id
  http_method             = aws_api_gateway_method.GetInterestMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_interest_calculator.invoke_arn
  timeout_milliseconds    = 29000

  request_parameters      = {
    "integration.request.header.X-Authorization" = "'static'"
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_interest_calculator.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.ACMEBankAPIGateway.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "ACMEBankInterestDeployment" {
  depends_on = [ aws_api_gateway_integration.GetInterestLambdaIntegration]

  rest_api_id = aws_api_gateway_rest_api.ACMEBankAPIGateway.id
  stage_name = "uat"

}

output "Public-API-Endpoint-URL" {
  value = "${aws_api_gateway_deployment.ACMEBankInterestDeployment.invoke_url}/getinterest"
}