resource "aws_iam_policy" "lambda_execution_logs_policy" {
  name        = "lambda-logs-execution-policy-${var.environment}"
  description = "Policy to allow lambda create logs steam and put logs."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}