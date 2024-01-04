variable "python_code_path" {
  description = "The location of python code in the project."
  type = string
}
variable "python_file_name" {
  description = "The python file name."
  type = string
}
variable "handler" {
  description = "The lambda function handler name."
  default= "lambda_handler"
  type = string
}
variable "role_arn" {
  description = "The role should be attached with this lambda."
  type = string
}
variable "environment" {
    description = "The environment name."
    type = string
}