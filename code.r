import pandas as pd
import numpy as np

# Your original dataframe
data = {' Col1': ['Bank Name','PNB','SIDBI', 'SBI', np.nan, np.nan],
        'Col2': ['Bank Name',' PNB', 'SIDBI', 'SBI', 'IDBI Bank', 'IDBI'],
        'Col3': ['Facility Type',' LT FBNFB ','LT FBNFB', 'LT FBNFB', 'LT FBNFB', 'LT FBNFB'],
        'Col4':[' Amount (Rs in crore) ', '1,000', '1,200', '3,200', '90', '1,035'],
        'Col5':['Rating', 'TICRAJAAA (Stable)', np.nan, np.nan, np.nan, np.nan],
        'Col6':['Rating', 'TICRAJAAA (Stable)', np.nan, 'ICRA', 'ICRAJAAA (Stable)', np.nan],
        'Col7':['Rating', 'TICRAJAAA (Stable)', 'AAA (Stable)', 'AAA (Stable)', np.nan, 'AAA (Stable)']}

df = pd.DataFrame(data)

# Function to merge columns based on the first row values
def merge_columns(df):
    merged_columns = []
    merged_values = []

    for col in df.columns:
        col_values = df[col].str.strip().str.lower().unique()
        col_values = [val for val in col_values if str(val) != 'nan']
        col_values_str = ' '.join(col_values)
        
        merged_columns.append(col)
        merged_values.append(col_values_str)

    result_df = pd.DataFrame({merged_columns[0]: df[merged_columns[0]]})
    
    for col, values in zip(merged_columns[1:], merged_values[1:]):
        result_df[col] = values

    return result_df

# Execute the function
result_df = merge_columns(df)

# Display the result
print(result_df)
