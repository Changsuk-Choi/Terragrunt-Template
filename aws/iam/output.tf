output "ec2_web_role_arn" {
  value = aws_iam_role.ec2_web_role.arn
}

output "ec2_web_role_name" {
  value = aws_iam_role.ec2_web_role.name
}

output "lambda_monitor_s3_role_arn" {
  value = aws_iam_role.lambda_monitor_s3_role.arn
}

output "lambda_monitor_s3_role_name" {
  value = aws_iam_role.lambda_monitor_s3_role.name
}
