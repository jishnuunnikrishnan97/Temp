import pandas as pd
import numpy as np


df = pd.DataFrame(data)

# Function to clean and combine values
def clean_and_combine(row):
    cleaned_values = [str(value).strip().lower() for value in row if pd.notna(value)]
    return ' '.join(cleaned_values) if len(set(cleaned_values)) > 1 else cleaned_values[0]

# Iterate through columns, apply the function to combine values
for col in df.columns:
    if col != 'Col1':  # Skip the first column
        unique_values = df[col].iloc[0]  # Values in the first row
        if len(set(unique_values)) > 1:
            df[col] = df[[col, 'Col1']].apply(clean_and_combine, axis=1)
            
# Drop duplicate columns
df = df.T.drop_duplicates().T

# Resultant dataframe
print(df)
