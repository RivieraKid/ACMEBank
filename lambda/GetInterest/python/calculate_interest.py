import json
from decimal import *

def lambda_handler(event, context):
    # TODO implement
    queryStringParameters = event["queryStringParameters"]
    balance = float(queryStringParameters["Balance"])
    # balance = 5001
    interestRate = 0.0
    interest = 0.0

    getcontext().prec = 2
    # getcontext().round = 
    if balance < 1000:
        interestRate = 0.01
    elif balance < 5000:
        interestRate = 0.015
    elif balance < 10000:
        interestRate = 0.02
    elif balance < 50000:
        interestRate = 0.025
    else:
        interestRate = 0.03
    
    interest = round(balance * interestRate, 2)

    return {
        'statusCode': 200,
        'body': json.dumps({
            "interest": interest
        })
    }
