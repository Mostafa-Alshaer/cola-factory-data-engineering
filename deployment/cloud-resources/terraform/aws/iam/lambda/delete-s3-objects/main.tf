resource "aws_iam_role" "role" {
  name = "cola-factory-data-team-delete-s3-objects-role-${var.environment}"

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