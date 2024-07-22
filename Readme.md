```

def find_row_with_elements(df, elements):
    for index, row in df.iterrows():
        if all(element in row.values for element in elements):
            return index
    return None



```