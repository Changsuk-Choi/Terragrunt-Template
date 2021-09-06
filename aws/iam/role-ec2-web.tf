data "aws_iam_policy_document" "ec2_web_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_web_role" {
  name               = "iam-${local.computed_name}-ec2-web-role"
  path               = "/ec2/"
  assume_role_policy = data.aws_iam_policy_document.ec2_web_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_web_job_policy" {
  statement {
    sid = "DownloadS3"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project}-*/*"
    ]
  }

  statement {
    sid = "GetDynamoDB"

    actions = [
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/ddb-${var.project}-${var.stage}-*",
      "arn:${data.aws_partition.current.partition}:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/ddb-${var.project}-${var.env}-*"
    ]
  }
}

resource "aws_iam_policy" "ec2_web_job_policy" {
  name   = "iam-${local.computed_name}-web-job-policy"
  path   = "/ec2/"
  policy = data.aws_iam_policy_document.ec2_web_job_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_web_job_policy_attachment" {
  role       = aws_iam_role.ec2_web_role.id
  policy_arn = aws_iam_policy.ec2_web_job_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_web_job_policy_aws_attachement" {
  role       = aws_iam_role.ec2_web_role.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
