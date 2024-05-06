
```

import openpyxl

# Load the workbook
wb = openpyxl.load_workbook('path_to_your_file.xlsx')

# Select a worksheet
sheet = wb.active

# Read a specific cell
print(sheet['A1'].value)

# Alternatively, you can loop through rows and columns
for row in sheet.iter_rows(min_row=1, max_row=2, min_col=1, max_col=2):
    for cell in row:
        print(cell.value)

# Close the workbook
wb.close()



```