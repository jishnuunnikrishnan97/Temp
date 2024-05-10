
```
def update_df1(df1, df2, search_value):
    # Search for the value in df2['Ref']
    match_row = df2[df2['Ref'] == search_value]
    
    if not match_row.empty:
        # Get corresponding values from df2
        cur_value = match_row['Cur'].values[0]
        amt_value = match_row['Amt'].values[0]
        
        # Update df1 with the corresponding values
        df1.loc[df1['Ref1'] == search_value, 'Cur1'] = cur_value
        df1.loc[df1['Ref1'] == search_value, 'Amt1'] = amt_value
```