import json
from urllib.parse import unquote

import boto3
import os


def lambda_handler(event, context):
    # extract s3 bucket and key
    s3_bucket_name = event['Records'][0]['s3']['bucket']['name']
    s3_key = unquote(event['Records'][0]['s3']['object']['key'])

    # copy the new object to process bucket
    s3_client = boto3.resource('s3')
    copy_source = {'Bucket': s3_bucket_name, 'Key': s3_key}
    s3_client.Object(os.environ["PROCESS_BUCKET"], os.environ["BATCH_PATH"] + s3_key).copy_from(CopySource=copy_source)
    print(f'Object with the key: {s3_key} copied successfully!')


# for run this code locally
if __name__ == '__main__':
    os.environ['PROCESS_BUCKET'] = 'cola-factory-process-data-mustafa-dev'
    os.environ["BATCH_PATH"] = 'batch/'
    with open('../input-sample/cola-factory-data-team-copy-to-process-input-sample.json') as json_file:
        event_for_testing = json.load(json_file)
    from collections import namedtuple
    Context = namedtuple('Context', 'invoked_function_arn function_version')
    lambda_handler(event_for_testing,
                   Context(
                       invoked_function_arn='arn:aws:lambda:us-east-1:XXX:function:cola-factory-data-team-copy-to'
                                            '-process',
                       function_version='$LATEST'))
