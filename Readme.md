
```
def get_ref_values(df):
    return df.loc[df['ext'].isnull() | df['ext'].eq('') | df['ext'].astype(str).eq('nan'), 'Ref'].tolist()
```