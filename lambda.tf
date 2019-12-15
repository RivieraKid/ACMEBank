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

  depends_on = [ null_resource.zipLambda ]
}