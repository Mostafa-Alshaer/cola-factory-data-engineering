resource "aws_s3_bucket" "cola-factory-process-data" {
  bucket = "cola-factory-process-data-${var.environment}"
  tags = {
    name  = "cola-factory-process-data-${var.environment}"
    owner = "data-team"
    environment = var.environment
    project = "cola-factory"
  }
}


