```

def vlookup(id_value, lookup_df):
    match = lookup_df[lookup_df['ref'] == id_value]
    if not match.empty:
        return match['FCY'].values[0]
    return None



def lookup_fcy(row, ref_df, id_col, ref_col, fcy_col):
    match = ref_df[ref_df[ref_col] == row[id_col]]
    if not match.empty:
        return match[fcy_col].values[0]
    return None




```