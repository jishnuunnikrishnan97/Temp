df['Amount'] = df.groupby('Customer ID')['Amount'].transform('sum')

# 2. Sum LT Amount for rows with the same Customer ID
df['LT Amount'] = df.groupby('Customer ID')['LT Amount'].transform('sum')
# Take the first non-null LT value for each Customer ID
df['LT'] = df.groupby('Customer ID')['LT'].transform(lambda x: x.ffill().iat[0])

# 3. Sum ST Amount for rows with the same Customer ID
df['ST Amount'] = df.groupby('Customer ID')['ST Amount'].transform('sum')
# Take the first non-null ST value for each Customer ID
df['ST'] = df.groupby('Customer ID')['ST'].transform(lambda x: x.ffill().iat[0])

# 4. Remove duplicate rows
df = df.drop_duplicates(subset='Customer ID')