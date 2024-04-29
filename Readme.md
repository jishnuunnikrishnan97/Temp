
```

import os
import pandas as pd
from pathlib import Path
from datetime import datetime

def format_datetime(dt):
    date_str1 = dt.strftime('%d%b%y')
    date_str2 = dt.strftime('%d%m%Y')
    date_str3 = dt.strftime('%d')
    return date_str1, date_str2, date_str3

output_dir = Path(os.path.join(os.getcwd(), 'Output'))
output_dir.mkdir(parents=True, exist_ok=True)

input_folder = os.path.join(os.getcwd(), 'Input')
main_dir = os.listdir(input_folder)

path = ""
E_kuber = ""
ISIN_Holding = ""
Repo_Collateral = ""
Repo_maturity = ""

for file in main_dir:
    if file.endswith('.xls') and 'Stock holding folderwise_Government Bonds' in file:
        path = os.path.join(input_folder, file)
        df = pd.read_excel(path, sheet_name='Detail listing')
        date = df.iloc[0, 1]
        ddmmmyy, ddmmyyyy, dd = format_datetime(date)
        df.columns = df.iloc[2]
        df = df.iloc[3:].reset_index(drop=True)

for other_file in main_dir:
    if not other_file.lower().endswith((".csv", ".xls")):
        if dd in other_file:
            E_kuber_path = os.path.join(input_folder, other_file)
            for xl_file in os.listdir(E_kuber_path):
                if xl_file.lower().endswith('.xls') and 'QHOLDSTMT' in xl_file:
                    E_kuber = os.path.join(E_kuber_path, xl_file)
    
    if other_file.lower().endswith(".csv") and ddmmmyy in other_file:
        if 'Memberwise_ISIN_Holding_Statement' in other_file:
            ISIN_Holding = os.path.join(input_folder, other_file)
        elif 'CBLOTri-party_Repo_Collateral_Status_Report' in other_file:
            Repo_Collateral = os.path.join(input_folder, other_file)
        elif 'Repo_Maturity_Datewise_Outstanding_Second_Leg_Report' in other_file:
            Repo_maturity = os.path.join(input_folder, other_file)


```