```

def vlookup(ref_value, lookup_df):
    if ref_value in lookup_df['id'].values:
        return ref_value
    return None

```