
```


def search_value_in_excel(file_path, search_value):
    wb = openpyxl.load_workbook(file_path)
    sheet_names = wb.sheetnames
    for sheet_name in sheet_names:
        sheet = wb[sheet_name]
        for row in sheet.iter_rows():
            for cell in row:
                if cell.value == search_value:
                    return sheet_name
    return None


```