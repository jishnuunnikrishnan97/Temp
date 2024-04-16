
```
import os
import pandas as pd

output_df = pd.DataFrame()

for folder in main_folder:
    folder_path = os.path.join(input_dir, folder)
    files = os.listdir(folder_path)

    deals_csv = [file for file in files if 'FCYFWD_Deals_Status_Report' in file and file.endswith('.csv')]
    trades_csv = [file for file in files if 'FCYFWD_Outstanding_Trades_Report' in file and file.endswith('.csv')]

    if not deals_csv or not trades_csv:
        continue

    deals_df = pd.read_csv(os.path.join(folder_path, deals_csv[0]), skiprows=1)
    trades_df = pd.read_csv(os.path.join(folder_path, trades_csv[0]), skiprows=1).rename(columns={'Member Ref Num': 'Transcation Reference No.'})

    merged_df = pd.merge(deals_df[['Transcation Reference No.']], trades_df[['Transcation Reference No.', 'Deal Received Time']], how='left', on='Transcation Reference No.')

    output_df = pd.concat([output_df, merged_df])

output_df.reset_index(drop=True, inplace=True)

```