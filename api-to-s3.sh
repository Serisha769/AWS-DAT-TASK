#!/bin/bash

# Prompt for AWS credentials with hidden input for security
read -p "Enter AWS Access Key ID: " aws_access_key_id
read -sp "Enter AWS Secret Access Key: " aws_secret_access_key
echo
read -p "Enter region: " region

# Configure AWS CLI with the provided credentials
aws configure set aws_access_key_id "$aws_access_key_id"
aws configure set aws_secret_access_key "$aws_secret_access_key"
aws configure set default.region "$region"

# Prompt for S3 bucket name and JSON file name
read -p "Enter your S3 bucket name: " BUCKET_NAME
read -p "Enter the JSON file name (e.g., data.json): " JSON_FILE

# Make the API call and save the result as a JSON file
curl -s "https://datausa.io/api/data?drilldowns=Nation&measures=Population" -o "$JSON_FILE"

# Upload the JSON file to the S3 bucket
aws s3 cp "$JSON_FILE" "s3://$BUCKET_NAME/$JSON_FILE"

# Clean up the JSON file
rm "$JSON_FILE"
echo "$JSON_FILE has been uploaded to s3://$BUCKET_NAME/ and deleted locally."