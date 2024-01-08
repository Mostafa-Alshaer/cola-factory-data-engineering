variable "database_name" {
    description = "The database name."
    type = string
}
variable "database_bucket_id" {
    description = "The id of S3 bucket to save the results of the query execution"
    type = string
}