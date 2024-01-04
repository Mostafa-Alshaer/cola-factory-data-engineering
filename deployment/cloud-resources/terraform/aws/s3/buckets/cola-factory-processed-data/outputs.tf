output "s3_bucket" {
  value       = aws_s3_bucket.cola-factory-processed-data
  description = "S3 cola factory processed data bucket."
}   
