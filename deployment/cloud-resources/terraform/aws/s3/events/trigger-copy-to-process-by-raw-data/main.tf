resource "aws_s3_bucket_notification" "trigger-copy-to-process-by-raw-data-event" {
  bucket = var.raw_data_bucket_id
  lambda_function {
    lambda_function_arn = var.copy_to_process_lambda_arn
    id                  = var.copy_to_process_lambda_id
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }
}

