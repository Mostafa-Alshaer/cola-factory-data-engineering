variable "copy_to_process_lambda_arn" {
  description = "The copy-to-process lambda arn."
  type = string
}

variable "raw_data_bucket_id" {
  default = "The id of raw data bucket."
  type = string
}

variable "copy_to_process_lambda_id" {
  default = "The id of copy-to-process lambda."
  type = string
}
