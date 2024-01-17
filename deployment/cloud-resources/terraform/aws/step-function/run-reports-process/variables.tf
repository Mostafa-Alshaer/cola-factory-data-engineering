variable "role_arn" {
  description = "The role should be attached with this lambda."
  type = string
}
variable "environment" {
    description = "The environment name."
    type = string
}
variable "move_s3_objects_lambda_arn" {
    description = "The arn for move s3 objects lambda"
    type = string
}
variable "delete_s3_objects_lambda_arn" {
    description = "The arn for delete s3 objects lambda"
    type = string
}
variable "read_config_file_lambda_arn" {
    description = "The arn for read config file lambda"
    type = string
}
variable "run_ctas_athena_lambda_arn" {
    description = "The arn for run ctas athena lambda"
    type = string
}