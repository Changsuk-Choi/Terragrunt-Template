data "archive_file" "zip" {
  type        = "zip"
  output_path = "${path.module}/${local.python_name}.zip"
  source_file = "${path.module}/${local.python_name}.py"
}

resource "aws_lambda_function" "monitor_s3" {
  function_name    = local.function_name
  handler          = "${local.python_name}.lambda_handler"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  timeout          = var.timeout
  memory_size      = var.memory_size
  runtime          = "python3.6"
  role             = data.terraform_remote_state.iam.outputs.lambda_monitor_s3_role_arn
  description      = "monitor s3 buckets size"

  environment {
    variables = {
      "stage_code" = upper(var.stage)
      "aws_region" = var.aws_region
    }
  }

  tags = merge(
    var.tags,
    tomap( { "Name" = local.function_name } )
  )
}

resource "aws_cloudwatch_event_rule" "monitor_s3" {
  name                = local.function_name
  description         = "Run lambda function: monitor-s3-size"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "monitor_s3" {
  target_id = local.function_name
  rule      = aws_cloudwatch_event_rule.monitor_s3.name
  arn       = aws_lambda_function.monitor_s3.arn
}

resource "aws_lambda_permission" "monitor_s3" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor_s3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monitor_s3.arn
}
