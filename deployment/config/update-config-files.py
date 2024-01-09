import os
import boto3

environment = os.environ["ENVIRONMENT"]
local_directory = os.getcwd().replace('deployment', 'src')
s3_bucket = f'cola-factory-process-data-{environment}'

for filename in os.listdir(local_directory):
    if filename.endswith('.json'):
        file_path = os.path.join(local_directory, filename)

        with open(file_path, 'r') as file:
            content = file.read()

        content = content.replace('${environment}', environment)

        s3_key = f'config/{filename}'
        s3 = boto3.client('s3')
        s3.put_object(Body=content, Bucket=s3_bucket, Key=s3_key)
