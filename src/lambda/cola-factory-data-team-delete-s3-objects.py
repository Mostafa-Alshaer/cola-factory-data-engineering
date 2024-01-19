import boto3
from pyathena import connect


def lambda_handler(event, context):
    # get event info
    database = event['database']
    work_group = event['work_group']
    to_delete_table_name = event['to_delete_table_name']
    to_delete_column_name = event['to_delete_column_name']
    bucket_name = event['bucket_name']
    read_to_delete_out_path = event['read_to_delete_out_path']

    # Set up Athena client
    # Create connection with PyAthena
    athena_client = connect(s3_staging_dir=f's3://{bucket_name}/{read_to_delete_out_path}',
                            region_name='us-east-1',
                            schema_name=database,
                            work_group=work_group
                            ).cursor()

    # Query Athena to get S3 keys
    query = f'SELECT {to_delete_column_name} FROM {to_delete_table_name};'
    result = athena_client.execute(query)

    # Extract S3 keys from the query result
    s3_paths = [row[0] for row in result]

    # Set up S3 client
    s3_client = boto3.client('s3')

    # Delete S3 objects in bulk
    objects_to_delete = [{'Key': s3_path.replace(f's3://{bucket_name}/', '')} for s3_path in s3_paths]

    # delete objects if there any need to be deleted
    if len(objects_to_delete) > 0:
        response = s3_client.delete_objects(
            Bucket=bucket_name,
            Delete={'Objects': objects_to_delete}
        )
        deleted_objects = response.get('Deleted', [])
        for deleted_object in deleted_objects:
            print(f"Deleted object: s3://{bucket_name}/{deleted_object['Key']}")


# for debugging lambda locally
if __name__ == '__main__':
    lambda_handler({
        "to_delete_table_name": "run_reports_to_delete_tbl",
        "to_delete_column_name": "s3_key",
        "bucket_name": "cola-factory-process-data-mostafadev",
        "read_to_delete_out_path": "read_to_delete_athena_out/",
        "database": "cola_process_data_mostafadev",
        "work_group": "cola_data_team_process_work_group_mostafadev"
    }, "")
