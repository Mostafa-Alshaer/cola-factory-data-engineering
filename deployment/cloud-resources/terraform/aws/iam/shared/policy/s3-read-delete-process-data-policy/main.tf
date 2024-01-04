resource "aws_iam_policy" "s3_read_delete_process_data_policy" {
  name        = "s3-read-and-delete-process-data-policy-${var.environment}"
  description = "Policy to allow S3 read, and delete objects in process data bucket."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ],
        Resource = "${var.process_data_bucket_arn}/*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket"
          ],
          "Resource": var.process_data_bucket_arn
      }
    ]
  })
}