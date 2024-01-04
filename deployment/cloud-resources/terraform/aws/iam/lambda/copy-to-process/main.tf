resource "aws_iam_role" "role" {
  name = "cola-factory-data-team-copy-to-process-role-${var.environment}"

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

resource "aws_iam_policy" "s3_read_raw_data_policy" {
  name        = "s3-read-raw-data-policy-${var.environment}"
  description = "Policy to allow S3 read from raw data bucket."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.raw_data_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_raw_data_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_read_raw_data_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution_logs_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.lambda_execution_logs_policy_arn
}

resource "aws_iam_policy" "s3_read_put_process_data_policy" {
  name        = "s3-read-put-process-data-policy-${var.environment}"
  description = "Policy to allow S3 read and write in process data bucket."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.process_data_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_put_process_data_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_read_put_process_data_policy.arn
}