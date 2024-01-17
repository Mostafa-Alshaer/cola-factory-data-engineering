resource "aws_sfn_state_machine" "run-reports-step-function" {
  name     = "cola-factory-data-team-run-reports-process-${var.environment}"
  role_arn = var.role_arn
  definition = templatefile("${path.module}/../../../../../../src/step-function/cola-factory-data-team-run-reports-process.json", {
    move_s3_objects_lambda_arn = var.move_s3_objects_lambda_arn,
    delete_s3_objects_lambda_arn = var.delete_s3_objects_lambda_arn,
    run_ctas_athena_lambda_arn = var.run_ctas_athena_lambda_arn,
    read_config_file_lambda_arn = var.read_config_file_lambda_arn
  })
}