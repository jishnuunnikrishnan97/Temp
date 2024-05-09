
```


check_existence = lambda x: x if x in df2['System ID'].values else None

df1['MU ref'] = df1['8Digit Ref'].apply(check_existence)


```