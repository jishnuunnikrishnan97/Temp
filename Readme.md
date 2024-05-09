
```

import numpy as np

def match_and_merge(df1, df2):
    # Create empty lists to store matched values
    matched_ref = []
    matched_cur = []
    matched_amt = []

    # Iterate over rows of df1
    for index, row in df1.iterrows():
        # Find matching row in df2 based on '8Digit ref' and 'Cur'
        match = df2[(df2['Ref'] == row['8Digit ref']) & (df2['Cur'] == row['Cur'])]

        # If match found, extract values
        if not match.empty:
            matched_ref.append(match['Ref'].values[0])
            matched_cur.append(match['Cur'].values[0])
            matched_amt.append(match['Amt'].values[0])
        else:
            # If no match found, append np.nan
            matched_ref.append(np.nan)
            matched_cur.append(np.nan)
            matched_amt.append(np.nan)

    # Add matched values as new columns to df1
    df1['Ref'] = matched_ref
    df1['Matched Cur'] = matched_cur
    df1['Matched Amt'] = matched_amt

    return df1

# Usage example:
# df1_matched = match_and_merge(df1, df2)



```