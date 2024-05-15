
```
import openpyxl

def search_value_in_excel(file_path, search_value):
    workbook = openpyxl.load_workbook(file_path, data_only=True)
    sheet_names = workbook.sheetnames

    for sheet_name in sheet_names:
        sheet = workbook[sheet_name]

        for row in sheet.iter_rows(values_only=True):
            for cell in row:
                if cell == search_value:
                    return sheet_name

    return None

```