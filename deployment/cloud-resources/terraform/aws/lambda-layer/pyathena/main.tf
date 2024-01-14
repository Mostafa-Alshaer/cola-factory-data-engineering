resource "aws_lambda_layer_version" "pyathena_lambda_layer" {
  layer_name = "pyathena_lambda_layer_${var.environment}"
  s3_bucket = "cola-factory-data-team-deployment"
  s3_key = "lambda-layers/version0/pyathena_layer.zip"
  compatible_runtimes = ["python3.9"]
}