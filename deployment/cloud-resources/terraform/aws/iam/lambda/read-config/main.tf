resource "aws_iam_role" "role" {
  name = "cola-factory-data-team-read-config-role-${var.environment}"

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

resource "aws_iam_policy" "s3_read_process_data_policy" {
  name        = "s3-read-process-data-policy-${var.environment}"
  description = "Policy to allow S3 read from process data bucket."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.process_data_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_process_data_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_read_process_data_policy.arn
}