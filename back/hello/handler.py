import json
import aurora_data_api

def getHello(event, context):
    print(event['query']["test"]) # get
    body = {
        "message": "[GET] Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "[GET] Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """

def postHello(event, context):
    print(event['body']["test"]) # post
    body = {
        "message": "[POST] Go Serverless v1.0! Your function executed successfully!",
        "input": event
    }

    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response

    # Use this code if you don't use the http event with the LAMBDA-PROXY
    # integration
    """
    return {
        "message": "[POST] Go Serverless v1.0! Your function executed successfully!",
        "event": event
    }
    """

