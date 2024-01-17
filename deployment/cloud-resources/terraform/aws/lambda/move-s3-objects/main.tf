resource "aws_lambda_function" "move-s3-objects-lambda" {
  filename         = "${var.python_code_path}/${var.python_file_name}.zip"
  function_name    = "${var.python_file_name}-${var.environment}"
  role             = var.role_arn
  handler          = "${var.python_file_name}.${var.handler}"
  runtime          = "python3.9"
  timeout          = 60
  source_code_hash = data.archive_file.zip_move_s3_objects_lambda_code.output_base64sha256
  tags = {
    name  = "${var.python_file_name}-${var.environment}"
    owner = "data-team"
    environment = var.environment
    project = "cola-factory"
  }
}