variable "process_data_bucket_arn" {
    description = "The process data bucket name."
    type = string
}
variable "lambda_execution_logs_policy_arn" {
    description = "The lambda execution logs policy arn."
    type = string
}
variable "s3_read_delete_process_data_policy_arn" {
    description = "The s3 read delete process data policy arn."
    type = string
}
variable "environment" {
    description = "The environment name."
    type = string
}