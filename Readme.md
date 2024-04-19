
```

def select_column(df):
    # Remove spaces from column names for comparison
    df.columns = df.columns.str.replace(' ', '')
    
    # Check if 'MemberReference' exists in column names
    if 'MemberReference' in df.columns:
        return 'MemberReference'
    else:
        # Check for columns with 'Member' within the first 5 columns
        for column in df.columns[:5]:
            if 'Member' in column:
                return column
        
        # If 'Member' not found in the first 5 columns, return the 4th column
        return df.columns[3]


```