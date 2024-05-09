
```

find_mu_ref = lambda x: df2.loc[df2['System ID'] == x, 'MU ref'].values[0] if x in df2['System ID'].values else None

# Apply the lambda function to create the new column
df1['MU ref'] = df1['8Digit Ref'].apply(find_mu_ref)


```