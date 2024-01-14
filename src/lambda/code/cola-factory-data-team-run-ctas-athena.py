import boto3
import time
import json
from pyathena import connect


def delete_mate_and_csv_files(bucket_name, path_to_delete):
    s3_client = boto3.client('s3')
    all_files = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=path_to_delete)
    if 'Contents' not in all_files:
        print(f'{bucket_name}/{path_to_delete} is empty')
    else:
        all_keys = all_files['Contents']
        print(f'{path_to_delete} {len(all_keys)} Total files')
        for key in all_keys:
            # delete csv and metadata files
            if key['Key'].split('.')[-1] in ['csv', 'metadata']:
                print(str(key['Key']) + ' Not Parquet File')
                s3_client.delete_object(Bucket=bucket_name, Key=key['Key'])
                print(str(key['Key']) + ' deleting succeed')


def wait_till_deletion_over(bucket_name, path_to_delete):
    s3_client = boto3.client('s3')
    time_passed = 0
    open_files = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=path_to_delete)
    for interval in range(10):
        if 'Contents' in open_files:
            print("The Deletion of {} folder is not over, going to sleep.".format(path_to_delete))
            time.sleep(1)
            time_passed += 1
        else:
            print("The {} folder is empty.".format(path_to_delete))
            break
    if time_passed > 8:
        print("The {} folder is not empty, try to delete again".format(path_to_delete))
        return 0
    else:
        return 1


def run_query_with_py_athena(query, output_location, data_base, work_group):
    # Create connection with PyAthena
    cursor = connect(s3_staging_dir=output_location,
                     region_name='us-east-1',
                     schema_name=data_base,
                     work_group=work_group
                     ).cursor()
    try:
        cursor.execute(query)
        query_id = cursor.query_id
        return query_id
    except Exception as e:
        print(e)
        raise Exception('The query is failed / canceled')


def lambda_handler(event, context):

    # get the needed event params
    bucket_name = event['bucket_name']
    data_base = event['data_base']
    work_group = event['work_group']
    drop_query = event['drop_query']
    ctas_query = event['ctas_query']
    drop_output_location = event['drop_output_location']
    ctas_output_location = event['ctas_output_location']

    # Delete files from ctas output location
    s3_resource = boto3.resource('s3')
    bucket = s3_resource.Bucket(bucket_name)
    bucket.objects.filter(Prefix=ctas_output_location).delete()
    if not wait_till_deletion_over(bucket_name, ctas_output_location):
        bucket.objects.filter(Prefix=ctas_output_location).delete()

    # Execute drop if exists query
    drop_query_id = run_query_with_py_athena(drop_query, f's3://{bucket_name}/{drop_output_location}',
                                             data_base, work_group)
    print(f'The query_id of the drop query {drop_query} is {drop_query_id}')

    # Execute CTAS query
    ctas_query_id = run_query_with_py_athena(ctas_query, f's3://{bucket_name}/{ctas_output_location}',
                                             data_base, work_group)
    print(f'The query_id of the ctas query {ctas_query} is {ctas_query_id}')

    # Delete ctas output meta data files
    delete_mate_and_csv_files(bucket_name, ctas_output_location)
    print(f'Deleting ctas output meta and csv files from {ctas_output_location}')

    return ctas_query_id


# for run this code locally
if __name__ == "__main__":
    with open('../input-sample/cola-factory-data-team-run-ctas-athena-input-sample.json') as json_file:
        event_for_testing = json.load(json_file)
    lambda_handler(event_for_testing, "")


