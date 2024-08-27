import boto3
import subprocess
import os
from datetime import datetime

def lambda_handler(event, context):
    # Copy the scripts to /tmp
    subprocess.run(['cp', '/var/task/api-to-s3.sh', '/tmp/api-to-s3.sh'], check=True)
    subprocess.run(['cp', '/var/task/s3-sync.sh', '/tmp/s3-sync.sh'], check=True)

    # Make the scripts executable
    os.chmod('/tmp/api-to-s3.sh', 0o755)
    os.chmod('/tmp/s3-sync.sh', 0o755)

    # Get the current date
    current_date = datetime.now().strftime('%Y-%m-%d')

    # Set environment variables dynamically
    bucket_name = os.environ.get('BUCKET_NAME', 's3-rearcdataquest')
    json_file = f"data_{current_date}.json"
    source_url = os.environ.get('SOURCE_URL', 'https://download.bls.gov/pub/time.series/pr/')

    # Execute api-to-s3.sh
    subprocess.run(['/tmp/api-to-s3.sh', bucket_name, json_file], check=True)

    # Execute s3-sync.sh
    subprocess.run(['/tmp/s3-sync.sh', bucket_name, source_url], check=True)

    return {
        'statusCode': 200,
        'body': 'Scripts executed successfully!'
    }