data "aws_iam_policy_document" "lambda_monitor_s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_monitor_s3_role" {
  name               = "iam-${local.computed_name}-lambda-monitor-s3-role"
  path               = "/lambda/"
  assume_role_policy = data.aws_iam_policy_document.lambda_monitor_s3_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_monitor_s3_job_policy" {
  statement {
    sid = "ListS3"

    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "GetCloudwatch"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "lambda_monitor_s3_job_policy" {
  name   = "iam-${local.computed_name}-lambda-monitor-s3-job-policy"
  path   = "/lambda/"
  policy = data.aws_iam_policy_document.lambda_monitor_s3_job_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_monitor_s3_policy_attachment" {
  role   = aws_iam_role.lambda_monitor_s3_role.id
  policy_arn = aws_iam_policy.lambda_monitor_s3_job_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_monitor_s3_role_allow_basic_execution" {
  role       = aws_iam_role.lambda_monitor_s3_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
