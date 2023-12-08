import pandas as pd

# Assuming your DataFrame is named 'df'
df = df.dropna(subset=['SSN'])  # Remove rows where 'SSN' is NaN
df = df[df['SSN'].astype(str).str.len() == 10]  # Keep rows with 'SSN' length equal to 10
