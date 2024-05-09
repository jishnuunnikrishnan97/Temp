
```

import pandas as pd
import numpy as np

def match_and_merge(df1, df2):
    # Create a dictionary from df2 where keys are tuples of ('Ref', 'Cur') and values are 'Amt'
    df2_dict = {(row['Ref'], row['Cur']): row['Amt'] for _, row in df2.iterrows()}
    
    # Initialize lists to store matched values
    ref_list = []
    fe_cur_list = []
    fe_amt_list = []
    
    # Iterate through rows of df1
    for _, row in df1.iterrows():
        # Check if the combination of '8Digit ref' and 'Cur' exists in df2
        if (row['8Digit ref'], row['Cur']) in df2_dict:
            # If found, append the values to the lists
            ref_list.append(row['8Digit ref'])
            fe_cur_list.append(row['Cur'])
            fe_amt_list.append(df2_dict[(row['8Digit ref'], row['Cur'])])
        else:
            # If not found, append NaN to the lists
            ref_list.append(np.nan)
            fe_cur_list.append(np.nan)
            fe_amt_list.append(np.nan)
    
    # Add the lists as new columns to df1
    df1['Ref'] = ref_list
    df1['fe Cur'] = fe_cur_list
    df1['fe Amt'] = fe_amt_list
    
    return df1

# Example usage:
# Assuming df1 and df2 are your dataframes
# Replace the column names with your actual column names

# Sample dataframes
df1 = pd.DataFrame({'8Digit ref': ['1', '2', '3'], 'Cur': ['USD', 'EUR', 'GBP']})
df2 = pd.DataFrame({'Ref': ['1', '2', '2'], 'Cur': ['USD', 'EUR', 'EUR'], 'Amt': [100, 200, 300]})

# Call the function to match and merge
result_df = match_and_merge(df1, df2)
print(result_df)



```