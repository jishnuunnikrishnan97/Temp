
```

def find_sheet_names(filename):
    # Load the Excel file without reading any data
    xl = pd.ExcelFile(filename)
    
    # Get list of sheet names
    sheet_names = xl.sheet_names
    
    # Define the substrings to search for in sheet names
    search_strings = ['Sheet1', 'Dump']
    
    # Filter sheet names containing any of the search strings
    matching_sheets = [sheet for sheet in sheet_names 
                       if any(s.lower() in sheet.lower() for s in search_strings)]
    
    return matching_sheets

```