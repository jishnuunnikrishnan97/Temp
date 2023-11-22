import pandas as pd

# Your list of strings
stringlist = ["nato", "mossad", "kgb"]

# Function to check if any element from stringlist exists in a table
def check_and_extract_table(sheet_name):
    df = pd.read_excel('your_excel_file.xlsx', sheet_name=sheet_name)
    for string in stringlist:
        if any(df.applymap(lambda cell: string in str(cell))):
            return df
    return None

# Iterate through sheets
result_dfs = []
excel_file = pd.ExcelFile('your_excel_file.xlsx')
for sheet_name in excel_file.sheet_names:
    result = check_and_extract_table(sheet_name)
    if result is not None:
        result_dfs.append(result)

# Now result_dfs contains the extracted tables as dataframes
