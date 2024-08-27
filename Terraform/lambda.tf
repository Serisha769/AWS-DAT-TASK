resource "aws_lambda_function" "run_scripts" {
  filename         = "my_lambda-part1-2.zip"
  function_name    = "RunScriptsLambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300
  environment {
    variables = {
      BUCKET_NAME  = "s3-rearcdataquest"
      REGION       = "us-east-1"
      SOURCE_URL   = "https://download.bls.gov/pub/time.series/pr/"
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name        = "DailyLambdaTrigger"
  description = "Triggers Lambda daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "lambda_target"
  arn = aws_lambda_function.run_scripts.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.run_scripts.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

