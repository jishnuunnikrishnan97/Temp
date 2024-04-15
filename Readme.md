
```
import zipfile
import pandas as pd
import os

def extract_data_from_zip(zip_file_path):
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        matched_files = [file for file in zip_ref.namelist() if 'Matched' in file]
        merged_df = pd.DataFrame()
        for file_name in matched_files:
            with zip_ref.open(file_name) as excel_file:
                df = pd.read_excel(excel_file)
                selected_columns = ['emp id', 'salary', 'age']
                df_selected = df[selected_columns]
                merged_df = pd.concat([merged_df, df_selected])
        return merged_df

zip_files_directory = 'path_to_directory_containing_zip_files'
dfs = []

for file_name in os.listdir(zip_files_directory):
    if file_name.endswith('.zip'):
        zip_file_path = os.path.join(zip_files_directory, file_name)
        df = extract_data_from_zip(zip_file_path)
        dfs.append(df)

merged_data = pd.concat(dfs)
output_excel_path = 'path_to_output_excel_file.xlsx'
merged_data.to_excel(output_excel_path, index=False)
print("Merged data has been written to:", output_excel_path)
```