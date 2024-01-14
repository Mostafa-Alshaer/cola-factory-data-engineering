data "archive_file" "zip_run_ctas_athena_lambda_code" {
  type        = "zip"
  source_file  = "${var.python_code_path}/${var.python_file_name}.py"
  output_path = "${var.python_code_path}/${var.python_file_name}.zip"
}