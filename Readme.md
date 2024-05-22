
```
df_fail = df1[df1['comment'] == 'fail']

# Step 2: Select rows with values 'import', 'lc', 'export', 'flash' in the column 'cty'
df_fail_cty = df_fail[df_fail['cty'].isin(['import', 'lc', 'export', 'flash'])]

# Step 3: Select rows with values 0 in the columns 'loan' and 'task'
final_df = df_fail_cty[(df_fail_cty['loan'] == 0) & (df_fail_cty['task'] == 0)]
```