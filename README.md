# ACME Bank account interest calculator
## Introduction
The brief was to provide an AWS lambda function that would calculate interest payable on an account balance in line with the table below:

| Account Balance | Interest Rate |
|-----------------|---------------|
| < £1,000 | 1.0% |
| £1,000 - £5,000 | 1.5% |
| £5,000 - £10,000 | 2.0% |
| £10,000 - £50,000 | 2.5% |
| > £50,000 | 3.0% |

In the interests of simplicity, interest is calculated for the entire balance based on the band it appears in, rather than calculating 1% for the first £1,000, 1.5% for the next £4,000, and so on.

In terms of the calculation as implemented, the ambiguity inherent in the boundary between two interest rates is resolved by assuming the lower bound in the range actually refers to that balance *plus* 1p, so for example, the 2.0% interest band actually starts at £5,000.01 in order to remove the ambiguity of whether £5,000 is in the 1.5% band or the 2.0% band.

The solution is provided as a small collection of terraform scripts, with a Python script for the Lambda function.

## Additional AWS Services used
In addition to Lambda, an API Gateway is used to provide access to the Lambda function, and the Lambda function logs an audit trail to CloudWatch.

I had considered providing a static web site hosted in S3 as the front-end to the API Gateway, but decided against it as in this context, it provides very little benefit over testing via the API Gateway, but also because an application such as this would not generally be directly available to the end user, rather it would be a small component of a greater app, which would then access it on behalf of the user.

## Deploying

Clone the repository with the following command:

```git clone https://github.com/RivieraKid/ACMEBank.git```

Change to the repository directory:

```cd ACMEBank```

The terraform scripts will deploy to the AWS eu-west-2 region, and will use your default AWS credentials (usually stored in ```${HOME}/.aws/credentials```

Initialise the terraform providers:

```terraform init```

Plan the deployment:

```terraform plan```

If the plan looks good, run:

```terraform apply```

When the resources are successfully deployed, terraform will provide the publically accessible URL for the API Gateway endpoint. Copy and paste this into a browser address bar and append ```?Balance=XXX```, where XXX should be replaced with the account balance to run the interest calculation on. For example: ```https://l290cj0f14.execute-api.eu-west-2.amazonaws.com/uat/getinterest?Balance=100000```. This will return a JSON object with the amount of interest that would be paid on a balance of £100,000:

```{"interest": 3000.0}```

Finally, run ```terraform destroy``` to clean up.