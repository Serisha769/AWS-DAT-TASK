import boto3
import pandas as pd
from datetime import datetime
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Get the current date
    current_date = datetime.now().strftime('%Y-%m-%d')
    
    # Construct the S3 URL for the JSON file
    bucket_name = "s3-rearcdataquest"
    json_file = f"data_{current_date}.json"
    url = f'https://{bucket_name}.s3.amazonaws.com/{json_file}'
    
    # Load the JSON data
    try:
        df_population = pd.read_json(url)
        logger.info("JSON data loaded successfully.")
    except Exception as e:
        logger.error(f"Failed to load JSON data: {e}")
        return {
            'statusCode': 500,
            'body': f"Failed to load JSON data: {e}"
        }
    
    # Perform calculations (e.g., mean and standard deviation)
    try:
        df_filtered = df_population[(df_population['Year'] >= 2013) & (df_population['Year'] <= 2018)]
        mean_population = df_filtered['Population'].mean()
        std_population = df_filtered['Population'].std()
        logger.info(f"Mean Population (2013-2018): {mean_population}")
        logger.info(f"Standard Deviation Population (2013-2018): {std_population}")
    except Exception as e:
        logger.error(f"Error during calculations: {e}")
        return {
            'statusCode': 500,
            'body': f"Error during calculations: {e}"
        }
    
    # Process the time-series data (Part 1)
    try:
        csv_url = 'https://s3-rearcdataquest.s3.amazonaws.com/pr.data.0.Current'
        df_spark = pd.read_csv(csv_url, sep='\t')

        # Process the time-series data
        df_grouped = df_spark.groupby(['series_id', 'year']).agg({'value': 'sum'}).reset_index()
        df_best_year = df_grouped.loc[df_grouped.groupby('series_id')['value'].idxmax()]

        logger.info("Best years for each series_id:")
        logger.info(df_best_year.to_dict(orient='records'))
    except Exception as e:
        logger.error(f"Failed to process Part 1 data: {e}")
        return {
            'statusCode': 500,
            'body': f"Failed to process Part 1 data: {e}"
        }
    
    # Generate report for series_id PRS30006032 and period Q01
    try:
        series_id = 'PRS30006032'
        period = 'Q01'
        df_filtered = df_spark[(df_spark['series_id'] == series_id) & (df_spark['period'] == period)]
        df_final = pd.merge(df_filtered, df_population, left_on='year', right_on='Year', how='inner')

        # Select and log the relevant columns
        df_report = df_final[['series_id', 'year', 'period', 'value', 'Population']]
        logger.info(f"Report for series_id {series_id} and period {period}:")
        logger.info(df_report.to_dict(orient='records'))
    except Exception as e:
        logger.error(f"Failed to generate report: {e}")
        return {
            'statusCode': 500,
            'body': f"Failed to generate report: {e}"
        }

    return {
        'statusCode': 200,
        'body': 'Processing completed successfully.'
    }