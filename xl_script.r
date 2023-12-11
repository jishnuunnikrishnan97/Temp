df = pd.DataFrame(data)

# Task 1: Summing amounts for rows with the same Cust ID, SSN, rating
df['amt'] = df.groupby(['Cust ID', 'SSN', 'rating'])['amt'].transform('sum')
df = df.drop_duplicates(['Cust ID', 'SSN', 'rating']).reset_index(drop=True)

# Task 2: Create new columns with unique values in the rating column
unique_ratings = df['rating'].unique()
for rating in unique_ratings:
    df[rating] = 0

# Task 3: Update columns based on different ratings
for index, row in df.iterrows():
    for rating in unique_ratings:
        if row['rating'] == rating:
            df.at[index, rating] = row['amt']

# Task 4: Remove the 'rating' column
df = df.drop(columns=['rating'])

# Displaying the final dataframe
print(df)
