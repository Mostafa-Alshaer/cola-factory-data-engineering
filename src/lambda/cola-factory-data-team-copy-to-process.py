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


# for debugging lambda locally
if __name__ == '__main__':
    os.environ['PROCESS_BUCKET'] = 'cola-factory-process-data-mostafadev'
    os.environ["BATCH_PATH"] = 'batch/'
    lambda_handler({
        "Records": [
            {
                "s3": {
                    "bucket": {
                        "name": "cola-factory-raw-data-mustafa-dev"
                    },
                    "object": {
                        "key": "run-reports/site_id=0001/machine_id=0001/year=2023/month=12/day=31/063fb882-8641-43e1"
                               "-9c2e-58bdb6dc696f.csv "
                    }
                }
            }
        ]
    }, "")
