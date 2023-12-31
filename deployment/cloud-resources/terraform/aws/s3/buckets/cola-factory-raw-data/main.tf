resource "aws_s3_bucket" "cola-factory-raw-data" {
  bucket = "cola-factory-raw-data-${var.environment}"
  tags = {
    name  = "cola-factory-raw-data-${var.environment}"
    owner = "data-engineering-team"
    environment = var.environment
    project = "cola-factory"
  }
}


