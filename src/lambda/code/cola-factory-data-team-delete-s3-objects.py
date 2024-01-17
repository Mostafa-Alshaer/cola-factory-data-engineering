import math
import multiprocessing

import awswrangler as wr
import boto3
import pandas as pd


def get_all_folders_inside_tables(bucket_name, key):
    s3_client = boto3.client('s3')
    paginator = s3_client.get_paginator('list_objects')
    result = paginator.paginate(Bucket=bucket_name, Delimiter='/', Prefix=key)
    folders = []
    for prefix in result.search('CommonPrefixes'):
        if prefix:
            folders.append(prefix.get('Prefix').split('/')[3])
    return folders


def delete_s3_objects(s3_keys, bucket_name):
    s3_client = boto3.resource('s3')
    for s3_key in s3_keys:
        s3_client.Object(bucket_name, s3_key).delete()


def split(array, parts):
    size = math.ceil(len(array) / parts)
    partial_arrays = []
    while len(array) > size:
        partial_array = array[:size]
        partial_arrays.append(partial_array)
        array = array[size:]
    partial_arrays.append(array)
    return partial_arrays


def clean_working_folders(all_data, working_folders_bucket_name):

    # extract kpi s3 keys to delete
    s3_keys = []
    for i, row in all_data.iterrows():
        s3_keys.append(row['s3_key'].replace("s3://" + working_folders_bucket_name + "/", ""))

    s3_keys_array_len = len(s3_keys)
    print("Deleting {} s3 objects we handled from working folders.".format(s3_keys_array_len))

    processes_count = min(s3_keys_array_len, 15)
    errors_s3_keys_sub_arrays = split(s3_keys, processes_count)
    processes = []
    try:
        for s3_keys_array in errors_s3_keys_sub_arrays:
            process = multiprocessing.Process(target=delete_s3_objects,
                                              args=(s3_keys_array, working_folders_bucket_name,))
            process.start()
            processes.append(process)
        # wait until each process is finished.
        for index, process in enumerate(processes):
            print("before joining deleting handled s3 objects process ", index)
            process.join()
            print("deleting handled s3 objects process ", index, "done")

    except:
        print("Error ! unable to start processes")


def lambda_handler(event, context):
    print(f'event: {event}')

    # get s3 resource instance
    s3_resource = boto3.resource('s3')
    print("Getting s3 resource instance succeed!")

    # get athena output bucket instance
    athena_output_bucket_name = event['bucket_name']
    athena_output_bucket = s3_resource.Bucket(athena_output_bucket_name)
    print("Getting athena output bucket instance succeed!")

    # get working folder bucket name
    working_folders_bucket_name = event['bucket_name']
    print("Getting working folder bucket name succeed!")

    # get to delete query out path 
    path = event['path']
    print("Getting to delete query out path succeed!")

    # get the athena output parquet files and content
    folders = get_all_folders_inside_tables(athena_output_bucket_name, path + "tables/")
    print("folders inside tables", folders)
    all_files_contents_list = []
    for folder in folders:
        athena_parquets_full_path = path + "tables/" + folder + "/"
        print("athena_parquets_full_path", athena_parquets_full_path)
        athena_output_parquet_files = athena_output_bucket.objects.filter(Prefix=athena_parquets_full_path)
        print("Getting athena output parquet files object summaries succeed")
        # get athena output parquet files and collect rows for each press
        for object_summary in athena_output_parquet_files:
            parquet_file_full_path = 's3://' + athena_output_bucket_name + '/' + object_summary.key
            parquet_file = wr.s3.read_parquet(path=parquet_file_full_path)
            all_files_contents_list.append(parquet_file)
    print("Getting the athena output parquet files and content succeed!")

    if len(all_files_contents_list) > 0:
        # concat all output parquet files
        all_files_content = pd.concat(all_files_contents_list)
        print("Contacting all output parquet files succeed!")
        clean_working_folders(all_files_content, working_folders_bucket_name)


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

