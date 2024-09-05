```
import pandas as pd
import re

def remove_special_chars(df, column_name):
    """Removes specified special characters from a DataFrame column.

    Args:
        df: The Pandas DataFrame.
        column_name: The name of the column to modify.

    Returns:
        The modified DataFrame.
    """

    # Regular expression pattern to match the special characters
    pattern = r'[-\(\)\*\,]'

    # Convert the column to string and remove the special characters using regex
    df[column_name] = df[column_name].astype(str).str.replace(pattern, '', regex=True)

    return df

```