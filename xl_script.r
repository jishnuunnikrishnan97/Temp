df['max_agency'] = df.iloc[:, 2:].idxmax(axis=1)

# Finding the corresponding maximum value
df['max_amount'] = df.apply(lambda row: row[row['max_agency']], axis=1)

# Sorting based on the preferred hierarchy
preferred_order = ['CRISIL', 'ICRA', 'IND', 'CARE', 'ACUITE']
df['max_agency'] = df['max_agency'].astype(pd.CategoricalDtype(categories=preferred_order, ordered=True))
df = df.sort_values(by=['max_agency'], ascending=False)

# Keeping only the desired columns
df = df[['Cust ID', 'SSN', 'ICRA', 'CRISIL', 'ACUITE', 'IND', 'CARE', 'max_agency', 'max_amount']]
