variable "raw_data_bucket_arn" {
    description = "The raw data bucket name."
    type = string
}
variable "process_data_bucket_arn" {
    description = "The process data bucket name."
    type = string
}
variable "environment" {
    description = "The environment name."
    type = string
}