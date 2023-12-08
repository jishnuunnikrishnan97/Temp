import pandas as pd

# Assuming your DataFrame is named 'df'
# Step 1
df['amt_sum'] = df.groupby(['Cust ID', 'SSN', 'rating'])['amt'].transform('sum')
df = df[df.duplicated(['Cust ID', 'SSN', 'rating'], keep=False) | ~df.duplicated(['Cust ID', 'SSN', 'rating'])]

# Step 2
unique_ratings = df['rating'].nunique()
df = pd.concat([df, pd.get_dummies(df['rating'])], axis=1)

# Step 3
for rating in df['rating'].unique():
    mask = (df.duplicated(['Cust ID', 'SSN']) & (df['rating'] == rating))
    df[rating] = df.loc[mask, 'amt']
    df.loc[mask, 'amt'] = df.loc[mask, 'amt'].sum()
df = df[~df.duplicated(['Cust ID', 'SSN'])]

# Step 4
df = df.drop('rating', axis=1)

# Display the resulting DataFrame
print(df)
