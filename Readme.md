
```

import pandas as pd

# Assuming you have two dataframes: df1 and df2

# Create a lambda function to check if the value exists in df1['8Digit Ref'] and return the corresponding 'MU' value
get_mu = lambda ref: df1.loc[df1['8Digit Ref'] == ref, 'MU'].iloc[0] if ref in df1['8Digit Ref'].values else ''

# Apply the lambda function to create the new column 'MU' in df2
df2['MU'] = df2['Ref'].apply(get_mu)


```