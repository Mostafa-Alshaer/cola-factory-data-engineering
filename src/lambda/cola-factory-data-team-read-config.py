import json
import os

import boto3


def lambda_handler(event, context):
    """
    Lambda function to retrieve and parse a JSON configuration file from an S3 bucket.

    Parameters:
    - event (dict): AWS Lambda event data.
    - context (object): AWS Lambda context.

    Returns:
    - dict: Parsed JSON data from the configuration file.
    """
    # Retrieve the S3 bucket and key
    s3_bucket = os.environ["PROCESS_BUCKET"]
    s3_key = event.get('config_s3_key')

    # Create an S3 client
    s3_client = boto3.client('s3')

    # Download the JSON file from S3
    response = s3_client.get_object(Bucket=s3_bucket, Key=s3_key)
    json_content = response['Body'].read().decode('utf-8')

    # Parse the JSON content
    json_data = json.loads(json_content)

    return json_data


# for debugging lambda locally
if __name__ == '__main__':
    os.environ['PROCESS_BUCKET'] = 'cola-factory-process-data-mostafadev'
    lambda_handler({
        "config_s3_key": "config/process-run-reports-config.json"
    }, "")
