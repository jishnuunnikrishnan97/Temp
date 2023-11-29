import pandas as pd

# Assuming df is your DataFrame
# Replace this with your actual DataFrame

# Example DataFrame
data = {'A': ['apple', 'orange', 'banana'],
        'B': ['apple', 'pear', 'banana'],
        'C': ['Apple', 'Orange', 'Banana']}
df = pd.DataFrame(data)

# Convert the values in the first row to lowercase and remove spaces
first_row_values = df.iloc[0].str.lower().str.strip()

# Iterate through the columns and combine if necessary
for col in df.columns:
    col_values = df[col].str.lower().str.strip()

    if (col_values == first_row_values).sum() >= 2:
        df[col] = ' '.join(col_values)

# Display the modified DataFrame
print(df)
