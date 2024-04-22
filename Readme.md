
```

import os
import zipfile
import pandas as pd

def extract_data_from_zip(zip_file_path):
    with zipfile.ZipFile(zip_file_path, mode='r') as zip_ref:
        matched_files = [file for file in zip_ref.namelist() if 'Matched' in file and 'Unmatched' not in file and file.endswith('.csv')]
        
        dfs = []
        for file_name in matched_files:
            with zip_ref.open(file_name) as excel_file:
                df = pd.read_csv(excel_file)
                df.columns = df.columns.str.replace(' ', '')
                selected_columns = [select_memref(df), select_tradedate(df), find_common_element(col_names, df.columns)]
                df_selected = df[selected_columns]
                new_col_names = {df_selected.columns[0]: "Member Reference", df_selected.columns[1]: "Trade Date", df_selected.columns[2]: 'Deal Received Data and Time'}
                df_selected = df_selected.rename(columns=new_col_names)
                dfs.append(df_selected)
        
        merged_df = pd.concat(dfs)
        return merged_df

main_path = os.path.join(os.getcwd(), 'Input')
month_merge_dfs = []

for month in os.listdir(main_path):
    month_path = os.path.join(main_path, month)
    daily_merge_dfs = []
    
    for day in os.listdir(month_path):
        day_path = os.path.join(month_path, day)
        daily_merged_df = pd.DataFrame()
        
        for zip_file in os.listdir(day_path):
            if zip_file.endswith('.zip'):
                df = extract_data_from_zip(os.path.join(day_path, zip_file))
                daily_merge_dfs.append(df)
        
        daily_merged_df = pd.concat(daily_merge_dfs)
        month_merge_dfs.append(daily_merged_df)
    
month_merge_df = pd.concat(month_merge_dfs)
output_excel_path = 'derv-input2.xlsx'
month_merge_df.to_excel(output_excel_path, index=False)


```