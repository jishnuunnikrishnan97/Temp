```
dicto['Remark'] = dicto['DIFFERENCE'].apply(
    lambda x: 'Pass' if pd.notnull(x) and x <= 20 else 'Fail' if pd.notnull(x) else None
)
```