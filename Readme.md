
```

import xlrd
import pandas as pd

# Open the Excel file
workbook = xlrd.open_workbook('your_file.xls')

# Select the first sheet (index 0)
sheet = workbook.sheet_by_index(0)

# Extract headers (assuming they are in the first row)
headers = [sheet.cell_value(0, col) for col in range(sheet.ncols)]

# Extract data rows
data = []
for row in range(1, sheet.nrows):
    data.append([sheet.cell_value(row, col) for col in range(sheet.ncols)])

# Create DataFrame
df = pd.DataFrame(data, columns=headers)

# Now you have your DataFrame ready for further analysis
print(df)




```