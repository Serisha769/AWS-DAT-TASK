#!/bin/bash

# Use environment variables for the S3 bucket name and source URL
BUCKET_NAME=${BUCKET_NAME}
SOURCE_URL=${SOURCE_URL}

# Ensure both environment variables are set
if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  exit 1
fi

if [ -z "$SOURCE_URL" ]; then
  echo "Error: SOURCE_URL environment variable is not set."
  exit 1
fi

# Set the directory variable for downloading files
DOWNLOAD_DIR="/tmp/s3source"

# Create the directory
mkdir -p "$DOWNLOAD_DIR"
echo "Created directory $DOWNLOAD_DIR for downloads"

# Download all files from the source URL into the directory
wget -nd -np -P "$DOWNLOAD_DIR" -r -R "index.html*"  \
--header="Host: $(echo $SOURCE_URL | awk -F/ '{print $3}')" \
--header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" \
"$SOURCE_URL"

# Sync the downloaded files to the S3 bucket
aws s3 sync "$DOWNLOAD_DIR" "s3://$BUCKET_NAME" --delete

# Clean up the directory
rm -rf "$DOWNLOAD_DIR"
echo "$DOWNLOAD_DIR directory deleted."