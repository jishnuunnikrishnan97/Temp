
```
import xlrd

def search_value_in_excel(file_path, search_value):
    workbook = xlrd.open_workbook(file_path)
    sheet_names = workbook.sheet_names()
    for sheet_name in sheet_names:
        sheet = workbook.sheet_by_name(sheet_name)
        for row_idx in range(sheet.nrows):
            for col_idx in range(sheet.ncols):
                cell_value = sheet.cell_value(row_idx, col_idx)
                if cell_value == search_value:
                    return sheet_name
    return None
```