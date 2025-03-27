import json
import base64

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    text = None
    if (event.get("body")):
        text = base64.b64decode(event["body"]) if (event.get("isBase64Encoded")) else event["body"]
    if (not text and event.get("rawPath")):
        text = event["rawPath"].split("/")[-1]
    if (not text):
        return {
            'statusCode': '400',
            'body': 'Missing text parameter. Supply it either in body or in path.',
        }
    return {
        'statusCode': '200',
        'body': text.swapcase(),
    }
