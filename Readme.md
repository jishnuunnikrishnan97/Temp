```
import pandas as pd

# Assuming your DataFrame is named 'df'
df['Difference'] = df['Exit'] - df['Enter']

# Convert the time delta to minutes and seconds
df['Difference'] = df['Difference'].dt.total_seconds() // 60
df['Difference'] = df['Difference'].apply(lambda x: f"{x:02d}:{(x % 60):02d}")

print(df)


```