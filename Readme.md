
```
import pandas as pd

# Assuming imex is your DataFrame

# First lookup
mid_ref1_na = imex['Lookup from SAA 1'].isna()
temp = imex.loc[~mid_ref1_na]
temp = temp.rename(columns={'Mid ref for Lookup 1': 'Mid ref for Lookup'})
imex_lookup = temp[['Mid ref for Lookup', 'CCY', 'FCY']]

# Second lookup
mid_ref2_na = imex['Lookup from SAA 2'].isna()
temp = imex.loc[~mid_ref2_na]
temp = temp.rename(columns={'Mid ref for Lookup 2': 'Mid ref for Lookup'})
temp = temp[['Mid ref for Lookup', 'CCY', 'FCY']]
imex_lookup = pd.concat([imex_lookup, temp])

# Third lookup
mid_ref3_na = imex['Lookup from SAA 3'].isna()
temp = imex.loc[~mid_ref3_na]
temp = temp.rename(columns={'Mid ref for Lookup 3': 'Mid ref for Lookup'})
temp = temp[['Mid ref for Lookup', 'CCY', 'FCY']]
imex_lookup = pd.concat([imex_lookup, temp])

# Display the final DataFrame
print(imex_lookup)

```