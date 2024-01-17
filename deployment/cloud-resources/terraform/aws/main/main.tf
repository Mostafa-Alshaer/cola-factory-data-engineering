# define some local variables to be passed to the different modules
locals {
  environment = terraform.workspace
  region = var.region
}
# bucket for the raw data of the cola factory
module cola-factory-raw-data {
  source     = "../s3/buckets/cola-factory-raw-data"
  environment  = local.environment
}
# bucket for the process data of the cola factory
module cola-factory-process-data {
  source     = "../s3/buckets/cola-factory-process-data"
  environment  = local.environment
}
# policy for lambda execution logs
module lambda-execution-logs-policy {
  source     = "../iam/shared/policy/lambda-execution-logs-policy"
  environment  = local.environment
}
# policy for s3 read delete process data policy
module s3-read-delete-process-data-policy {
  source     = "../iam/shared/policy/s3-read-delete-process-data-policy"
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  environment  = local.environment
}
# iam for the copy-to-process lambda
module iam-copy-to-process-lambda {
  source     = "../iam/lambda/copy-to-process"
  raw_data_bucket_arn  = module.cola-factory-raw-data.s3_bucket.arn
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  lambda_execution_logs_policy_arn = module.lambda-execution-logs-policy.lambda_execution_logs_policy.arn
  environment  = local.environment
}
# copy to process lambda
module copy-to-process-lambda {
  source            = "../lambda/copy-to-process"
  python_code_path = "../../../../../src/lambda/code"
  python_file_name = "cola-factory-data-team-copy-to-process"
  role_arn = module.iam-copy-to-process-lambda.copy_to_process_lambda_role.arn
  environment  = local.environment
  process_data_bucket_name = replace(module.cola-factory-process-data.s3_bucket.arn, "arn:aws:s3:::", "")
}
# trigger copy to process lambda by s3 raw data events
module trigger-copy-to-process-by-raw-data {
  source            = "../s3/events/trigger-copy-to-process-by-raw-data"
  copy_to_process_lambda_arn = module.copy-to-process-lambda.copy-to-process-lambda.arn
  raw_data_bucket_id = module.cola-factory-raw-data.s3_bucket.id
  copy_to_process_lambda_id = module.copy-to-process-lambda.copy-to-process-lambda.id
}
# permission to trigger copy to process lambda by s3 raw data events
module trigger-copy-to-process-by-raw-data-permission {
  source            = "../iam/s3/events/trigger-copy-to-process-by-raw-data"
  copy_to_process_lambda_arn = module.copy-to-process-lambda.copy-to-process-lambda.arn
  raw_data_bucket_arn = module.cola-factory-raw-data.s3_bucket.arn
}
# bucket for the processed data of the cola factory
module cola-factory-processed-data {
  source     = "../s3/buckets/cola-factory-processed-data"
  environment  = local.environment
}
# iam for the delete-s3-objects lambda
module iam-delete-s3-objects-lambda {
  source     = "../iam/lambda/delete-s3-objects"
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  lambda_execution_logs_policy_arn = module.lambda-execution-logs-policy.lambda_execution_logs_policy.arn
  s3_read_delete_process_data_policy_arn = module.s3-read-delete-process-data-policy.s3_read_delete_process_data_policy.arn
  environment  = local.environment
}
# delete s3 objects lambda
module delete-s3-objects-lambda {
  source            = "../lambda/delete-s3-objects"
  python_code_path = "../../../../../src/lambda/code"
  python_file_name = "cola-factory-data-team-delete-s3-objects"
  role_arn = module.iam-delete-s3-objects-lambda.delete_s3_objects_lambda_role.arn
  environment  = local.environment
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python39:2"]
}
# iam for the move-s3-objects lambda
module iam-move-s3-objects-lambda {
  source     = "../iam/lambda/move-s3-objects"
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  processed_data_bucket_arn = module.cola-factory-processed-data.s3_bucket.arn
  lambda_execution_logs_policy_arn = module.lambda-execution-logs-policy.lambda_execution_logs_policy.arn
  s3_read_delete_process_data_policy_arn = module.s3-read-delete-process-data-policy.s3_read_delete_process_data_policy.arn
  environment  = local.environment
}
# move s3 objects lambda
module move-s3-objects-lambda {
  source            = "../lambda/move-s3-objects"
  python_code_path = "../../../../../src/lambda/code"
  python_file_name = "cola-factory-data-team-move-s3-objects"
  role_arn = module.iam-move-s3-objects-lambda.move_s3_objects_lambda_role.arn
  environment  = local.environment
}
# athena workgroup for cola factory data team project
module cola-factory-athena-workgroup {
  source     = "../athena/work-group"
  environment  = local.environment
}
# athena database process data for cola factory data team project
module cola-factory-athena-process-database {
  source     = "../athena/database"
  database_bucket_id = module.cola-factory-process-data.s3_bucket.id
  database_name = "cola_process_data_${local.environment}"
}
# iam for the read-config lambda
module iam-read-config-lambda {
  source     = "../iam/lambda/read-config"
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  lambda_execution_logs_policy_arn = module.lambda-execution-logs-policy.lambda_execution_logs_policy.arn
  environment  = local.environment
}
# read config lambda
module read-config-lambda {
  source            = "../lambda/read-config"
  python_code_path = "../../../../../src/lambda/code"
  python_file_name = "cola-factory-data-team-read-config"
  role_arn = module.iam-read-config-lambda.read_config_lambda_role.arn
  environment  = local.environment
  process_data_bucket_name = replace(module.cola-factory-process-data.s3_bucket.arn, "arn:aws:s3:::", "")
}
# iam for the run-ctas-athena lambda
module iam-run-ctas-athena-lambda {
  source     = "../iam/lambda/run-ctas-athena"
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
  lambda_execution_logs_policy_arn = module.lambda-execution-logs-policy.lambda_execution_logs_policy.arn
  s3_read_delete_process_data_policy_arn = module.s3-read-delete-process-data-policy.s3_read_delete_process_data_policy.arn
  environment  = local.environment
  athena_work_group_arn = module.cola-factory-athena-workgroup.workgroup.arn
}
# run ctas athena lambda
module run-ctas-athena-lambda {
  source            = "../lambda/run-ctas-athena"
  python_code_path = "../../../../../src/lambda/code"
  python_file_name = "cola-factory-data-team-run-ctas-athena"
  role_arn = module.iam-run-ctas-athena-lambda.run_ctas_athena_lambda_role.arn
  environment  = local.environment
  pyathena_lambda_layer_arn = module.pyathena-lambda-layer.pyathena_layer.arn
}
# pyathena layer
module pyathena-lambda-layer {
  source            = "../lambda-layer/pyathena"
  environment  = local.environment
}
# iam for the run reports step function
module iam-run-reports-process-step-function {
  source     = "../iam/step-function/run-reports-process"
  environment  = local.environment
  lambdas_arns = [module.read-config-lambda.read-config-lambda.arn,
                  module.run-ctas-athena-lambda.run-ctas-athena-lambda.arn,
                  module.delete-s3-objects-lambda.delete-s3-objects-lambda.arn,
                  module.move-s3-objects-lambda.move-s3-objects-lambda.arn]
}
# run reports step function
module run-reports-process-step-function {
  source     = "../step-function/run-reports-process"
  role_arn  = module.iam-run-reports-process-step-function.run_reports_step_function_role.arn
  environment = local.environment
  read_config_file_lambda_arn = module.read-config-lambda.read-config-lambda.arn
  run_ctas_athena_lambda_arn = module.run-ctas-athena-lambda.run-ctas-athena-lambda.arn
  delete_s3_objects_lambda_arn = module.delete-s3-objects-lambda.delete-s3-objects-lambda.arn
  move_s3_objects_lambda_arn = module.move-s3-objects-lambda.move-s3-objects-lambda.arn
}