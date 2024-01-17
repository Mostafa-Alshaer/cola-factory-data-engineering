import os
import re
import boto3


def get_local_script_numbers(path):
    """
    Get the list of script numbers from local file names.
    """
    script_numbers = []
    try:
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith('.sql'):
                    script_number = extract_script_number(file)
                    if script_number is not None:
                        script_numbers.append(script_number)
    except Exception as e:
        print(f"Error extracting script numbers from local files: {e}")
    return script_numbers


def extract_script_number(file_name):
    """
    Extract script number from the file name using a regular expression.
    """
    match = re.search(r'(\d+)', file_name)
    if match:
        return int(match.group(1))
    else:
        return None


def check_s3_object_exists(bucket_name, key):
    """
    Check if a specific S3 object exists.
    """
    s3 = boto3.client('s3')
    try:
        s3.head_object(Bucket=bucket_name, Key=key)
        return True
    except Exception as e:
        if '404' in str(e):  # The object does not exist (404 Not Found error)
            return False
        else:
            print(f"Error checking S3 object existence: {e}")
            return False


def read_s3_object(bucket_name, key):
    """
    Read the content of a specific S3 object.
    """
    s3 = boto3.client('s3')
    try:
        response = s3.get_object(Bucket=bucket_name, Key=key)
        object_content = response['Body'].read().decode('utf-8')
        return object_content
    except Exception as e:
        print(f"Error reading S3 object: {e}")
        return None


def write_s3_object(bucket_name, key, content):
    """
    Write content to a specific S3 object.
    """
    s3 = boto3.client('s3')
    try:
        s3.put_object(Body=content, Bucket=bucket_name, Key=key)
    except Exception as e:
        print(f"Error writing S3 object: {e}")


def execute_athena_query(query, output_location, database='your_database'):
    """
    Execute an Athena query and return the result.
    """
    athena = boto3.client('athena',
                          region_name='us-east-1')
    response = athena.start_query_execution(
        QueryString=query,
        QueryExecutionContext={'Database': database},
        ResultConfiguration={'OutputLocation': output_location},
        WorkGroup=f'cola_data_team_process_work_group_{environment}'
    )
    query_execution_id = response['QueryExecutionId']

    # Wait for the query to complete
    waiter = athena.get_waiter('query_execution_complete')
    waiter.wait(QueryExecutionId=query_execution_id)

    # Get the query results
    results = athena.get_query_results(QueryExecutionId=query_execution_id)

    return results


# Replace these values with your specific path, S3, and Athena information
environment = os.environ["ENVIRONMENT"]
local_path = os.getcwd().replace('deployment/athena-schema', 'src/athena')
s3_bucket_name = f'cola-factory-data-team-deployment'
s3_object_key = f'athena-schema/last-schema-script-numbers/environment={environment}/last-schema-script-number.txt '
athena_output_location = f's3://cola-factory-data-team-deployment/athena-schema/creating-output/ '
athena_database = f'cola_process_data_{environment}'


# Step 1: Get local script numbers
local_script_numbers = get_local_script_numbers(local_path)
print("Local Script Numbers:")
print(local_script_numbers)

# Step 2: Check if S3 object exists
if check_s3_object_exists(s3_bucket_name, s3_object_key):
    # Step 3: Read S3 object
    last_executed_script_number = int(read_s3_object(s3_bucket_name, s3_object_key) or 0)
else:
    last_executed_script_number = 0

print(f"\nLast Executed Script Number from S3: {last_executed_script_number}")

# Step 4: Execute scripts with a number higher than the last executed script number
for script_file in sorted([f for f in os.listdir(local_path) if f.endswith('.sql')]):
    script_number = extract_script_number(script_file)

    if script_number is not None and script_number > last_executed_script_number:
        # Read the content of the SQL file
        try:
            script_file_path = os.path.join(local_path, script_file)
            with open(script_file_path, 'r') as file:
                query = file.read()
                query = query.replace('${environment}', environment)
                print(f"Executing Athena query for script {script_number}")
                # Execute Athena query
                result = execute_athena_query(query, athena_output_location, database=athena_database)
                # Process the result (replace this comment with your result processing logic)
                # For example, you can print the result rows
                for row in result['ResultSet']['Rows']:
                    print([field['VarCharValue'] for field in row['Data']])
        except Exception as e:
            print(f"Error reading or executing SQL file {script_file}: {e}")

# Step 5: Update S3 object with the last executed script number
new_last_executed_script_number = max(local_script_numbers)
write_s3_object(s3_bucket_name, s3_object_key, str(new_last_executed_script_number))

print(f"\nUpdated S3 Object with Last Executed Script Number: {new_last_executed_script_number}")
