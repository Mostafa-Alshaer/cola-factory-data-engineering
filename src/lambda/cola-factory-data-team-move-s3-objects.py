import boto3
import os


def lambda_handler(event, context):
    """
    Lambda function to move objects from one S3 bucket/path to another.

    Parameters:
    - event (dict): AWS Lambda event data.
    - context (object): AWS Lambda context.

    Returns:
    - None
    """
    # Ensure that the necessary environment variables are set
    source_bucket = event.get('source_bucket')
    source_path = event.get('source_path', '')
    destination_bucket = event.get('destination_bucket')
    destination_path = event.get('destination_path', '')

    # Create an S3 client
    s3_client = boto3.client('s3')

    # mete files extensions that should not be moved to the final destination
    meta_data_files_extensions = ['csv', 'metadata']

    # List all objects in the source S3 bucket and path
    objects_to_move = []
    response = s3_client.list_objects_v2(Bucket=source_bucket, Prefix=source_path)
    for obj in response.get('Contents', []):
        objects_to_move.append(obj['Key'])

    # Move objects from the source to the destination S3 bucket and path
    for s3_object_key in objects_to_move:

        if s3_object_key.split('.')[-1] in meta_data_files_extensions:
            continue

        copy_source = {'Bucket': source_bucket, 'Key': s3_object_key}
        destination_key = os.path.join(destination_path,
                                       '/'.join(os.path.relpath(s3_object_key, source_path).split('/')[1:]))

        s3_client.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=destination_key)
        s3_client.delete_object(Bucket=source_bucket, Key=s3_object_key)

        print(f"Moved object: s3://{source_bucket}/{s3_object_key} to s3://{destination_bucket}/{destination_key}")


# for debugging lambda locally
if __name__ == '__main__':
    lambda_handler({
        "source_bucket": "cola-factory-raw-data-mustafa-dev",
        "source_path": "",
        "destination_bucket": "cola-factory-process-data-mustafa-dev",
        "destination_path": "batch/"
    }, "")
