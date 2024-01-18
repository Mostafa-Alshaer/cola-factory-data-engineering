resource "aws_lambda_function" "read-config-lambda" {
  filename         = "${var.python_code_path}/${var.python_file_name}.zip"
  function_name    = "${var.python_file_name}-${var.environment}"
  role             = var.role_arn
  handler          = "${var.python_file_name}.${var.handler}"
  runtime          = "python3.9"
  timeout          = 20
  source_code_hash = data.archive_file.zip_read_config_lambda_code.output_base64sha256
  environment {
    variables = {
      PROCESS_BUCKET = var.process_data_bucket_name
    }
  }
  tags = {
    name  = "${var.python_file_name}-${var.environment}"
    owner = "data-team"
    environment = var.environment
    project = "cola-factory"
  }
}