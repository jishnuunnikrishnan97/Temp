```

import os
from src.bigquery_agent import BigQueryAgent, bigquery # Import what's needed
import pandas as pd
import logging
 
# Optional: Load .env file if you are using one
# from dotenv import load_dotenv
# load_dotenv()
 
# --- CONFIGURATION ---
# Get from environment variables or hardcode for simplicity here
MY_PROJECT_ID = os.getenv("GCP_PROJECT_ID", "sherif-440815") # <--- CHANGE THIS or set env var
MY_DATASET_ID = "my_agent_dataset"
MY_TABLE_ID_DF = "my_table_from_df"
MY_TABLE_ID_CSV = "my_table_from_csv"
MY_GCS_BUCKET = os.getenv("GCS_BUCKET_NAME", "kgs-kdn-india-storage-bucket") # <--- CHANGE THIS or set env var
 
# Check if GOOGLE_APPLICATION_CREDENTIALS is set
if not os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
    logging.error("GOOGLE_APPLICATION_CREDENTIALS environment variable not set.")
    logging.info("Please set it to the path of your service account key JSON file.")
    # Example: export GOOGLE_APPLICATION_CREDENTIALS=\"/path/to/credentials/your-service-account-file.json\"")
    exit(1)
# --- END CONFIGURATION ---
 
 
if MY_PROJECT_ID == "your-gcp-project-id" or MY_GCS_BUCKET == "your-gcs-bucket-name":
    logging.warning("Please update MY_PROJECT_ID and MY_GCS_BUCKET in run.py or set environment variables.")
    # exit(1) # Optionally exit if not configured
 
def main():
    logging.info(f"Starting BigQuery Agent for project: {MY_PROJECT_ID}, dataset: {MY_DATASET_ID}")
 
    agent = BigQueryAgent(project_id=MY_PROJECT_ID, dataset_id=MY_DATASET_ID)
 
    # 1. Upload from Pandas DataFrame
    data = {
        'name': ['Alice', 'Bob', 'Charlie', 'David'],
        'age': [30, 24, 29, 35],
        'city': ['New York', 'Paris', 'London', 'Berlin']
    }
    sample_df = pd.DataFrame(data)
    agent.upload_dataframe(sample_df, MY_TABLE_ID_DF, write_disposition="WRITE_TRUNCATE")
 
    # 2. Upload from Local CSV
    csv_file_path = "sample_data.csv" # Will be created in the root project directory
    with open(csv_file_path, "w") as f:
        f.write("id,product,quantity,price\n")
        f.write("1,Laptop,10,1200.50\n")
        f.write("2,Mouse,50,25.99\n")
        f.write("3,Keyboard,25,75.00\n")
        f.write("4,Monitor,5,300.75\n")
 
    agent.upload_csv_from_local(csv_file_path, MY_TABLE_ID_CSV, skip_leading_rows=1, write_disposition="WRITE_TRUNCATE")
 
    # 3. Query data to DataFrame
    query = f"SELECT name, age FROM `{MY_PROJECT_ID}.{MY_DATASET_ID}.{MY_TABLE_ID_DF}` WHERE age > 25 ORDER BY age DESC"
    results_df = agent.query_to_dataframe(query)
    logging.info("Query results (DataFrame):\n" + results_df.to_string())
 
    # 4. Query data as iterable
    query_all_products = f"SELECT * FROM `{MY_PROJECT_ID}.{MY_DATASET_ID}.{MY_TABLE_ID_CSV}`"
    logging.info("Query results (Iterable):")
    for row in agent.query_to_iterable(query_all_products):
        logging.info(f"  ID: {row['id']}, Product: {row['product']}, Quantity: {row['quantity']}, Price: {row.get('price', 'N/A')}") # Access by column name
 
 
    # --- Optional: GCS Operations (Uncomment and ensure bucket/permissions are set up) ---
    # # Example: First upload the local CSV to GCS using gsutil or google-cloud-storage library
    # # For this example, we assume sample_data.csv is already in GCS
    # gcs_file_uri = f"gs://{MY_GCS_BUCKET}/data_uploads/sample_data.csv"
    # logging.info(f"Ensure {csv_file_path} is uploaded to {gcs_file_uri} before proceeding with GCS upload to BQ.")
    # # agent.upload_from_gcs(gcs_file_uri, "my_table_from_gcs_upload", skip_leading_rows=1, write_disposition="WRITE_TRUNCATE")
 
 
    # # Example: Extract table to GCS
    # extract_uri_pattern = f"gs://{MY_GCS_BUCKET}/data_extracts/{MY_TABLE_ID_DF}-export-*.csv.gz"
    # agent.extract_table_to_gcs(MY_TABLE_ID_DF, extract_uri_pattern)
    # logging.info(f"Table {MY_TABLE_ID_DF} extracted to GCS: {extract_uri_pattern}")
 
    logging.info("BigQuery Agent operations complete.")
 
if __name__ == "__main__":
    main()

```
