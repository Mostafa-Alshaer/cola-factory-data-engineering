resource "aws_lambda_function" "run-ctas-athena-lambda" {
  filename         = "${var.python_code_path}/${var.python_file_name}.zip"
  function_name    = "${var.python_file_name}-${var.environment}"
  role             = var.role_arn
  handler          = "${var.python_file_name}.${var.handler}"
  runtime          = "python3.9"
  timeout          = 20
  source_code_hash = data.archive_file.zip_run_ctas_athena_lambda_code.output_base64sha256
  layers           = [var.pyathena_lambda_layer_arn]
  tags = {
    name  = "${var.python_file_name}-${var.environment}"
    owner = "data-team"
    environment = var.environment
    project = "cola-factory"
  }
}