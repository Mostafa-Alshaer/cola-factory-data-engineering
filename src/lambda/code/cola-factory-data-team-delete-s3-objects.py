import boto3


def lambda_handler(event, context):
    # Ensure that the necessary environment variables are set
    s3_bucket = event.get('bucket_name')
    s3_path = event.get('path', '')

    # Create an S3 client
    s3_client = boto3.client('s3')

    # List all objects in the specified S3 bucket and path
    objects_to_delete = []
    response = s3_client.list_objects_v2(Bucket=s3_bucket, Prefix=s3_path)
    for obj in response.get('Contents', []):
        objects_to_delete.append(obj['Key'])

    # Delete objects from the specified S3 bucket and path
    for s3_object_key in objects_to_delete:
        s3_client.delete_object(Bucket=s3_bucket, Key=s3_object_key)
        print(f"Deleted object: s3://{s3_bucket}/{s3_object_key}")


# for run this code locally
if __name__ == '__main__':
    import json
    with open('../input-sample/cola-factory-data-team-delete-s3-objects-input-sample.json') as json_file:
        event_for_testing = json.load(json_file)
    from collections import namedtuple
    Context = namedtuple('Context', 'invoked_function_arn function_version')
    lambda_handler(event_for_testing,
                   Context(
                       invoked_function_arn='arn:aws:lambda:us-east-1:XXX:function:cola-factory-data-team-delete-s3'
                                            '-objects',
                       function_version='$LATEST'))

