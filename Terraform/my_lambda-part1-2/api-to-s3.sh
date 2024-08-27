#!/bin/bash

# Use environment variables for the S3 bucket name and JSON file name
BUCKET_NAME=${BUCKET_NAME}
JSON_FILE=${JSON_FILE}

# Ensure both environment variables are set
if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  exit 1
fi

if [ -z "$JSON_FILE" ]; then
  echo "Error: JSON_FILE environment variable is not set."
  exit 1
fi

# Make the API call and save the result as a JSON file
curl -s "https://datausa.io/api/data?drilldowns=Nation&measures=Population" -o "/tmp/$JSON_FILE"

# Upload the JSON file to the S3 bucket
aws s3 cp "/tmp/$JSON_FILE" "s3://$BUCKET_NAME/$JSON_FILE"

# Clean up the JSON file
rm "/tmp/$JSON_FILE"
echo "$JSON_FILE has been uploaded to s3://$BUCKET_NAME/ and deleted locally."