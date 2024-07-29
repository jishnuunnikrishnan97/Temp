```
import pandas as pd

# Sample function to search for a string in a column and populate a new column
def search_and_populate(row, search_string, column_name):
    # Check if the search string is in the specified column
    if search_string.lower() in str(row[column_name]).lower():
        return search_string
    else:
        return None  # or "" if you prefer empty strings

# Example usage
data = {
    'Text': ['This is a test', 'Another example', 'Searching for words', 'No match here'],
}
df = pd.DataFrame(data)

# Define the search string
search_string = 'test'

# Apply the function to the DataFrame
df['Search_Result'] = df.apply(search_and_populate, search_string=search_string, column_name='Text', axis=1)

# Display the DataFrame
print(df)



```