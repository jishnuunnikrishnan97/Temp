```

import pandas as pd
import re

# Sample DataFrame
data = {'reference': ['FXD946511492-1', 'ABC12345', 'XYZ98765-3']}
df = pd.DataFrame(data)

# Function to extract the desired part of the string
def extract_numbers(reference):
    match = re.search(r'[A-Za-z]+(\d+)(?:-|$)', reference)
    if match:
        return match.group(1)
    return None

# Apply the function to the 'reference' column
df['extracted'] = df['reference'].apply(extract_numbers)

print(df)


```