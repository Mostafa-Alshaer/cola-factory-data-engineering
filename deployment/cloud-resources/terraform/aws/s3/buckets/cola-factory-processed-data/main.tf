resource "aws_s3_bucket" "cola-factory-processed-data" {
  bucket = "cola-factory-processed-data-${var.environment}"
  tags = {
    name  = "cola-factory-processed-data-${var.environment}"
    owner = "data-team"
    environment = var.environment
    project = "cola-factory"
  }
}


