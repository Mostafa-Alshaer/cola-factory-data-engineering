resource "aws_iam_role" "role" {
  name = "cola-factory-data-team-move-s3-objects-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_logs_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.lambda_execution_logs_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_delete_process_data_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.s3_read_delete_process_data_policy_arn
}

resource "aws_iam_policy" "s3_read_put_processed_data_policy" {
  name        = "s3-read-put-processed-data-policy-${var.environment}"
  description = "Policy to allow S3 read, and put objects in processed data bucket."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.processed_data_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_put_processed_data_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_read_put_processed_data_policy.arn
}