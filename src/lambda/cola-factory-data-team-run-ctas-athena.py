import boto3
from pyathena import connect


def delete_s3_objects_by_path(bucket_name, path_prefix, file_extensions=None):
    """
    Delete objects in an S3 bucket based on a given path prefix and optional file extensions.

    Parameters:
    - bucket_name (str): The name of the S3 bucket.
    - path_prefix (str): The path prefix to filter objects for deletion.
    - file_extensions (list, optional): A list of file extensions to filter objects for deletion.

    Returns:
    - list: A list of deleted object keys.
    """
    s3_client = boto3.client('s3')

    # List objects in the specified path
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=path_prefix)

    # Extract object keys from the response
    object_keys = [obj['Key'] for obj in response.get('Contents', [])]

    if not object_keys:
        print(f"No objects found in the path: s3://{bucket_name}/{path_prefix}")
        return []

    # Filter objects based on file extensions if provided
    if file_extensions:
        object_keys = [key for key in object_keys if key.endswith(tuple(file_extensions))]

    if not object_keys:
        print(f"No objects found with the specified file extensions in the path: s3://{bucket_name}/{path_prefix}")
        return []

    # Delete objects using delete_objects
    objects_to_delete = [{'Key': object_key} for object_key in object_keys]

    response = s3_client.delete_objects(
        Bucket=bucket_name,
        Delete={'Objects': objects_to_delete}
    )

    deleted_objects = response.get('Deleted', [])
    deleted_object_keys = [obj['Key'] for obj in deleted_objects]

    for deleted_object_key in deleted_object_keys:
        print(f"Deleted object: s3://{bucket_name}/{deleted_object_key}")

    return deleted_object_keys


def run_athena_query(query, database, output_location, workgroup):
    """
    Run an Athena query and print the query ID.

    Parameters:
    - query (str): The SQL query to be executed.
    - database (str): The name of the Athena database.
    - output_location (str): The S3 location where query results will be stored.
    - workgroup (str, optional): The Athena workgroup. If not provided, the default workgroup is used.
    """
    # Establish a connection to Athena
    connection = connect(s3_staging_dir=output_location,
                         region_name='us-east-1',
                         schema_name=database,
                         work_group=workgroup)

    # Create a cursor
    cursor = connection.cursor()

    # Execute the query
    cursor.execute(query)

    # Get the query ID
    query_id = cursor.query_id
    print(f"Athena Query ID for the query '{query}': {query_id}")

    # Close the cursor and connection
    cursor.close()
    connection.close()


def lambda_handler(event, context):
    """
    Lambda function to perform a sequence of operations including deleting S3 objects,
    executing Athena queries, and deleting additional S3 objects.

    Parameters:
    - event (dict): AWS Lambda event data.
    - context (object): AWS Lambda context.

    Returns:
    - None
    """
    # get the needed event params
    bucket_name = event['bucket_name']
    data_base = event['data_base']
    work_group = event['work_group']
    drop_query = event['drop_query']
    ctas_query = event['ctas_query']
    drop_output_location = event['drop_output_location']
    ctas_output_location = event['ctas_output_location']

    # Delete files from ctas output location
    deleted_objects = delete_s3_objects_by_path(bucket_name, ctas_output_location)
    print(f"Deleted objects: {deleted_objects}")

    # Execute drop if exists query
    run_athena_query(drop_query, data_base, f's3://{bucket_name}/{drop_output_location}', work_group)

    # Execute CTAS query
    run_athena_query(ctas_query, data_base, f's3://{bucket_name}/{ctas_output_location}', work_group)

    # Delete meta data files
    delete_s3_objects_by_path(bucket_name, ctas_output_location, ['csv', 'metadata'])
    print(f"Deleted meta and csv objects: {deleted_objects}")


# for debugging lambda locally
if __name__ == "__main__":
    lambda_handler({
        "bucket_name": "cola-factory-process-data-mostafadev",
        "data_base": "cola_process_data_mostafadev",
        "work_group": "cola_data_team_process_work_group_mostafadev",
        "drop_query": "DROP TABLE IF EXISTS run_reports_leftover_tbl",
        "ctas_query": "CREATE TABLE run_reports_leftover_tbl WITH (format = 'Parquet', parquet_compression = "
                      "'SNAPPY') AS SELECT * FROM run_reports_leftover_view",
        "drop_output_location": "leftover/drop/",
        "ctas_output_location": "leftover/ctas/"
    }, "")
