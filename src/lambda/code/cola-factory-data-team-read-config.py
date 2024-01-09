import json
import os

import boto3


def lambda_handler(event, context):
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


# for run this code locally
if __name__ == '__main__':
    import json
    with open('../input-sample/cola-factory-data-team-read-config-input-sample.json') as json_file:
        event_for_testing = json.load(json_file)
    from collections import namedtuple
    Context = namedtuple('Context', 'invoked_function_arn function_version')
    lambda_handler(event_for_testing,
                   Context(
                       invoked_function_arn='arn:aws:lambda:us-east-1:XXX:function:cola-factory-data-team-read-config',
                       function_version='$LATEST'))

