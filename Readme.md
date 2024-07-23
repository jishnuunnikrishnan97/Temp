```

def vlookup(id_value, lookup_df):
    match = lookup_df[lookup_df['ref'] == id_value]
    if not match.empty:
        return match['FCY'].values[0]
    return None


```