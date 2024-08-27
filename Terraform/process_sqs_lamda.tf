resource "aws_lambda_function" "process_sqs" {
  filename         = "my_lambda-part3.zip"
  function_name    = "ProcessSQSLambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300

  environment {
    variables = {
      BUCKET_NAME = "s3-rearcdataquest"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.data_pipeline_queue.arn
  function_name    = aws_lambda_function.process_sqs.arn
  batch_size       = 10
}