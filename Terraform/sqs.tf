resource "aws_sqs_queue" "data_pipeline_queue" {
  name = "DataPipelineQueue"
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = "s3-rearcdataquest"

  queue {
    queue_arn     = aws_sqs_queue.data_pipeline_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}