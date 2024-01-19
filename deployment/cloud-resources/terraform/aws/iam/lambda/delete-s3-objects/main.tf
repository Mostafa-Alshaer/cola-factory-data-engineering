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

resource "aws_iam_policy" "run_athena_policy_no_partition" {
  name        = "run-athena-policy-no-partition-${var.environment}"
  description = "Policy to allow running athena queries"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "glue:GetTable",
          "athena:GetWorkGroup",
          "athena:StopQueryExecution",
          "glue:GetDatabase"

        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_run_athena_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.run_athena_policy_no_partition.arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution_logs_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.lambda_execution_logs_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_read_delete_process_data_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = var.s3_read_delete_process_data_policy_arn
}

resource "aws_iam_policy" "athena_full_s3_process_bucket_policy" {
  name        = "full_s3_process_bucket_for_to_delete-policy-${var.environment}"
  description = "Policy to allow athena to access needed APIs in s3."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        Resource = [
          "${var.process_data_bucket_arn}/*",
          var.process_data_bucket_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "full_s3_process_bucket_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.athena_full_s3_process_bucket_policy.arn
}

resource "aws_iam_policy" "glue_database_policy" {
  name        = "athena-glue-database-for-delete-lambda-policy-${var.environment}"
  description = "Policy to allow to access needed APIs in glue."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:DeleteTable",
          "glue:CreateTable"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_database_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.glue_database_policy.arn
}