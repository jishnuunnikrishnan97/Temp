import pandas as pd

def format_column_to_three_digits(input_excel, output_excel, column_name):
    # Read Excel file into DataFrame
    df = pd.read_excel(input_excel)

    # Format the specified column to have three digits
    df[column_name] = df[column_name].astype(str).str.zfill(3)

    # Write the modified DataFrame to a new Excel file
    df.to_excel(output_excel, index=False)

# Replace 'input.xlsx', 'output.xlsx', and 'YourColumnName' with actual file paths and column name
format_column_to_three_digits('input.xlsx', 'output.xlsx', 'YourColumnName')
