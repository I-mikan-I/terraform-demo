import json


def handler(event, context):
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps("Hello Lambda!"),
        "headers": {
            "content-type": "application/json"
        }
    }
