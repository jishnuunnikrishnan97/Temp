import pandas as pd

# Replace 'YourDataFrame.csv' with your actual DataFrame and provide the correct Excel file path
df = pd.read_csv('YourDataFrame.csv')
excel_file_path = 'AllIndiaExpFT30Sep23_Final v1_Working for LT & ST breakup.xlsb'

# Perform VLOOKUP calculation
result_series = df['A'].map(
    pd.read_excel(excel_file_path, sheet_name='F&T Sep23', usecols="A,M", skiprows=3, nrows=5587)
    .set_index('A')
    .iloc[:, 0]
) * -1000

# Add the result series to your DataFrame
df['Result'] = result_series

# Now df['Result'] contains the calculated values
