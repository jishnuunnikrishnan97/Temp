
```

index_to_drop = df.index[df.isnull().all(axis=1)][0]  # Find the index of the first row with all NaN values
df.drop(index=df.index[index_to_drop:], inplace=True)  # Drop rows from the index onwards
```