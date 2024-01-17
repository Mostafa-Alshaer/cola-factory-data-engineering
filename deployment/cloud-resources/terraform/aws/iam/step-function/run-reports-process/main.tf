resource "aws_iam_role" "role" {
  name = "cola-factory-data-team-run-reports-process-role-${var.environment}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_policy" "sf_invoke_lambdas_policy" {
  name        = "invoke-lambdas-by-run-reports-step-function-policy-${var.environment}"
  description = "Policy to allow SF to invoke needed lambdas"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": var.lambdas_arns
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sf_role_lambdas_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.sf_invoke_lambdas_policy.arn
}

resource "aws_iam_policy" "sf_xray_policy" {
  name        = "s3-xray-run-reports-step-function-policy-${var.environment}"
  description = "Policy to allow SF to invoke needed xray APIs"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sf_role_xray_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.sf_xray_policy.arn
}