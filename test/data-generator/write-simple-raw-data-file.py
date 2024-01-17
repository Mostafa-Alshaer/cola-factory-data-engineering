import boto3
import uuid
from datetime import datetime, timezone


def generate_csv_data(num_records):
    csv_data = []

    for i in range(num_records):
        record_id = str(uuid.uuid4())
        record_branch_id = '0001'
        record_machine_id = '0001'
        record_type = 'start' if i % 2 == 0 else 'stop'
        record_time = datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()

        csv_data.append([record_id, record_type, record_time, record_branch_id, record_machine_id])

    return csv_data


def write_csv_to_s3(csv_data, bucket_name, key):
    s3 = boto3.client('s3')

    csv_string = '\n'.join([','.join(row) for row in csv_data])

    s3.put_object(Body=csv_string, Bucket=bucket_name, Key=key)


if __name__ == "__main__":

    csv_data_sample = generate_csv_data(9)

    bucket_name_example = 'cola-factory-raw-data-mostafadev'
    key_example = f'run-reports/year=2024/month=01/day=03/{str(uuid.uuid4())}.csv'

    write_csv_to_s3(csv_data_sample, bucket_name_example, key_example)

    print(f"CSV file has been successfully uploaded to S3 bucket '{bucket_name_example}' with key '{key_example}'.")
