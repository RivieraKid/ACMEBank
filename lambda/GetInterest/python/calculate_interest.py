import json
from decimal import *
import logging
import math

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    if ( "queryStringParameters" not in event ):
        print ("Invalid Query")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'Message': 'Invalid Query'
            })
        }
    queryStringParameters = event["queryStringParameters"]

    if "Balance" not in queryStringParameters:
        print ("No Balance provided in HTTP call")
        return {
            'statusCode': 502,
            'body': json.dumps({
                'Message': "No Balance provided in HTTP call"
            })
        }

    balance = float(queryStringParameters["Balance"])
    resource = event["resource"]
    httpMethod = event["httpMethod"]

    if ( resource != "/getinterest" ):
        print ("Unknown resource in request - \"" + resource + "\"")
        return {
            'statusCode': 404,
            'body': json.dumps({
                "Message": "Unknown resource in request"
            })
        }

    if ( httpMethod != "GET" ):
        print ("Unknown method in HTTP call - \"" + httpMethod + "\"")
        return {
            'statusCode': 502,
            'body': json.dumps({
                'Message': "Unknown method in HTTP call"
            })
        }

    if ( balance <= 0 ):
        print ("No interest earned for balances of zero or less")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'Interest': 0
            })
        }

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

    interest = math.ceil(((balance * interestRate) * 100)) / 100

    headers = {
            'OriginalBalance': balance,
            'InterestRateApplied': str(interestRate * 100) + "%"
        }

    print ("Response Headers: " + json.dumps(headers))
    print ("Interest to be paid: " + str(interest))

    return {
        'statusCode': 200,
        'body': json.dumps({
            'interest': interest
        }),
        'headers': headers
    }
