variable "process_data_bucket_arn" {
    description = "The process data bucket arn."
    type = string
}
variable "lambda_execution_logs_policy_arn" {
    description = "The lambda execution logs policy arn."
    type = string
}
variable "environment" {
    description = "The environment name."
    type = string
}