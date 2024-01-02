resource "aws_lambda_permission" "raw_data_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.copy_to_process_lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_data_bucket_arn
}

