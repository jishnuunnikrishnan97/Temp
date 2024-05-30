
```
def remove_rows_between_subtotal_and_no(df, col_name='NO', start_value='Sub Total :', end_value='NO'):
    index_list = df.index[df[col_name] == start_value].tolist()
    rows_to_drop = []

    for start_index in index_list:
        end_index = None
        for i in range(1, 7):
            if start_index + i < len(df) and df.iloc[start_index + i][col_name] == end_value:
                end_index = start_index + i
                break
        if end_index is not None:
            rows_to_drop.extend(range(start_index, end_index + 1))

    df = df.drop(rows_to_drop).reset_index(drop=True)
    return df
```