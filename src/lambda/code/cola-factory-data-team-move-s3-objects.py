import boto3
import os


def lambda_handler(event, context):
    # Ensure that the necessary environment variables are set
    source_bucket = event.get('source_bucket')
    source_path = event.get('source_path', '')
    destination_bucket = event.get('destination_bucket')
    destination_path = event.get('destination_path', '')

    # Create an S3 client
    s3_client = boto3.client('s3')

    # List all objects in the source S3 bucket and path
    objects_to_move = []
    response = s3_client.list_objects_v2(Bucket=source_bucket, Prefix=source_path)
    for obj in response.get('Contents', []):
        objects_to_move.append(obj['Key'])

    # Move objects from the source to the destination S3 bucket and path
    for s3_object_key in objects_to_move:
        copy_source = {'Bucket': source_bucket, 'Key': s3_object_key}
        destination_key = os.path.join(destination_path, os.path.relpath(s3_object_key, source_path))

        s3_client.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=destination_key)
        s3_client.delete_object(Bucket=source_bucket, Key=s3_object_key)

        print(f"Moved object: s3://{source_bucket}/{s3_object_key} to s3://{destination_bucket}/{destination_key}")


# for run this code locally
if __name__ == '__main__':
    import json
    with open('../input-sample/cola-factory-data-team-move-s3-objects-input-sample.json') as json_file:
        event_for_testing = json.load(json_file)
    from collections import namedtuple
    Context = namedtuple('Context', 'invoked_function_arn function_version')
    lambda_handler(event_for_testing,
                   Context(
                       invoked_function_arn='arn:aws:lambda:us-east-1:XXX:function:cola-factory-data-team-move-s3'
                                            '-objects',
                       function_version='$LATEST'))

