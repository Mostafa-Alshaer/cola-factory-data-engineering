resource "aws_athena_database" "cola_db" {
  name   = var.database_name
  bucket = var.database_bucket_id
}