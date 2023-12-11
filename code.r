pattern = r'^\d{3}-\d{6}$'

# Use the 'str.match' function to check if each value in the column follows the pattern
mask = df['Customer ID'].str.match(pattern)

# Identify rows that don't match the pattern
invalid_rows = df[~mask]