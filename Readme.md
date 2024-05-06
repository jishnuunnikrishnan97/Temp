
```

import xlrd
import pandas as pd

def read_excel_to_dataframe(file_path):
    # Open the Excel file
    workbook = xlrd.open_workbook(file_path)

    # Select the first sheet (index 0)
    sheet = workbook.sheet_by_index(0)

    # Extract headers (assuming they are in the first row)
    headers = [sheet.cell_value(0, col) for col in range(sheet.ncols)]

    # Extract data rows starting from the 8th row (index 7)
    data = []
    for row in range(7, sheet.nrows):
        data.append([sheet.cell_value(row, col) for col in range(sheet.ncols)])

    # Create DataFrame
    df = pd.DataFrame(data, columns=headers)

    return df

# Usage example:
file_path = 'your_file.xls'  # Replace 'your_file.xls' with the actual path to your Excel file
df = read_excel_to_dataframe(file_path)
print(df)



```