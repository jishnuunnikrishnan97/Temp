import pandas as pd

# Assuming your DataFrame is named df
# Task 1
df['amt'] = df.groupby(['Cust ID', 'SSN', 'rating'])['amt'].transform('sum')
df = df.drop_duplicates(['Cust ID', 'SSN', 'rating']).reset_index(drop=True)

# Task 2
unique_ratings = df['rating'].nunique()
df = pd.concat([df, pd.DataFrame(0, index=df.index, columns=[f'rating_{i}' for i in range(unique_ratings)])], axis=1)

# Task 3
for index, row in df.iterrows():
    same_cust_ssn = df[(df['Cust ID'] == row['Cust ID']) & (df['SSN'] == row['SSN'])]
    if len(same_cust_ssn['rating'].unique()) > 1:
        for rating in same_cust_ssn['rating'].unique():
            df.loc[index, f'rating_{rating}'] = same_cust_ssn[same_cust_ssn['rating'] == rating]['amt'].sum()
        df = df.drop(same_cust_ssn.index.difference([index]))

# Task 4
df = df.drop('rating', axis=1)

# Display the resulting DataFrame
print(df)
