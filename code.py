import pandas as pd

# Your list of strings
stringlist = ["nato", "mossad", "kgb"]

# Function to check if any whole element from stringlist exists in a table
def check_and_extract_table(sheet_name):
    df = pd.read_excel('your_excel_file.xlsx', sheet_name=sheet_name)
    
    for column in df.columns:
        for string in stringlist:
            if any(df[column].astype(str).str.contains(rf'\b{string}\b', case=False, regex=True)):
                return df
    
    return None
