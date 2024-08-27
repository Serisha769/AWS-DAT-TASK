#!/bin/bash

# Alert: Ensure that AWS CLI and wget are installed before running this script
echo "Alert: Ensure that AWS CLI and wget are installed before running this script."
echo "AWS CLI installation guide: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
echo "wget installation guide: https://www.gnu.org/software/wget/"

# Prompt for AWS credentials with hidden input for security
read -p "Enter AWS Access Key ID: " aws_access_key_id
read -sp "Enter AWS Secret Access Key: " aws_secret_access_key
echo
read -p "Enter region: " region

# Configure AWS CLI with the provided credentials
aws configure set aws_access_key_id "$aws_access_key_id"
aws configure set aws_secret_access_key "$aws_secret_access_key"
aws configure set default.region "$region"

# Prompt for S3 bucket name and source URL
read -p "Enter your S3 bucket name: " BUCKET_NAME
read -p "Enter the source URL: " SOURCE_URL

# Set the directory variable for downloading files
DOWNLOAD_DIR="s3source"

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

# Explanation of wget options used:
# -nd: Do not create a directory hierarchy; store all files in the specified directory.
# -np: Do not ascend to the parent directory when recursively downloading.
# -P: Specifies the directory prefix where files should be saved.
# -r: Enables recursive download.
# -R "index.html*": Rejects files matching the pattern (e.g., index.html).
# Reference: https://rakeshjain-devops.medium.com/download-files-and-directories-from-web-using-curl-and-wget-9217bc2e34c9