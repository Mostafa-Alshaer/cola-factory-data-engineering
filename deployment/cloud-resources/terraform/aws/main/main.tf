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
# iam for the copy-to-process lambda
module iam-copy-to-process-lambda {
  source     = "../iam/lambda/copy-to-process"
  raw_data_bucket_arn  = module.cola-factory-raw-data.s3_bucket.arn
  process_data_bucket_arn = module.cola-factory-process-data.s3_bucket.arn
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