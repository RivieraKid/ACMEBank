resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "null_resource" "zipLambda" {
    triggers = {
        policy_sha1 = "${sha1(file("lambda/GetInterest/python/calculate_interest.py"))}"
    }

    provisioner "local-exec" {
        command = "cd lambda/GetInterest/python && rm -f calculate_interest.zip && zip calculate_interest.zip calculate_interest.py"
    }
}

resource "aws_lambda_function" "lambda_interest_calculator" {
  filename      = "lambda/GetInterest/python/calculate_interest.zip"
  function_name = "${var.bank_name}InterestCalc"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "calculate_interest.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda/GetInterest/python/calculate_interest.zip")

  runtime = "python3.8"

  timeout = "30"

  depends_on = [ null_resource.zipLambda, aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.example ]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.bank_name}InterestCalc"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}