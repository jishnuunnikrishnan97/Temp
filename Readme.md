
```

find_ref = lambda x: df2.loc[df2['Ref'] == x, 'Ref'].iloc[0] if x in df2['Ref'].values else None

# Apply the lambda function to create the new column
df1['MU'] = df1['8Digit Ref'].apply(find_ref)


```