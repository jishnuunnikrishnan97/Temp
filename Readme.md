```

import pandas as pd

def find_matching_row(df):
    for index, row in df.iterrows():
        if all(row[col] == col for col in df.columns):
            return index
    return None

# Example usage:
data = {'A': ['A', 'B', 'C'], 'B': ['B', 'B', 'B'], 'C': ['C', 'B', 'C']}
df = pd.DataFrame(data)
print(find_matching_row(df))  # Output: 0




```