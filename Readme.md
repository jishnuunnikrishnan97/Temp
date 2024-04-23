
```

import pandas as pd
import os
from pathlib import Path
import zipfile

def extract_data_from_zip(zip_file_path):
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        # Filtering specific files within the ZIP
        matched_files = [file for file in zip_ref.namelist() if 'Client_Trades_status_for_INRFWD' in file and file.endswith('.csv')]
        dfs = []
        for file_name in matched_files:
            with zip_ref.open(file_name) as excel_file:
                df = pd.read_csv(excel_file)
                selected_columns = ['Transaction Reference No', 'Reporting Date and Time']
                dfs.append(df[selected_columns])
        return pd.concat(dfs) if dfs else pd.DataFrame()

def process_month_data(input_dir):
    input_path = Path(input_dir)
    month_merge_df = pd.DataFrame()
    for month_folder in input_path.iterdir():
        daily_dfs = []
        for day_folder in month_folder.iterdir():
            if day_folder.is_dir():
                for zip_file in day_folder.glob('*.zip'):
                    daily_dfs.append(extract_data_from_zip(zip_file))
        # Consolidating all day dataframes into one for the month
        if daily_dfs:
            month_merge_df = pd.concat([month_merge_df, pd.concat(daily_dfs)], ignore_index=True)
    return month_merge_df

# Adjust the 'Input' directory path as necessary
input_dir = os.path.join(os.getcwd(), 'Input')
final_df = process_month_data(input_dir)


```