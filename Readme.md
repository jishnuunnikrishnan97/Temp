
```
# Assuming your DataFrame is named df and the column containing the dates is named 'date_column'
df['date_column'] = pd.to_datetime(df['date_column'])

# Extracting date and time components into separate columns
df['Date'] = df['date_column'].dt.strftime('%d/%m/%Y')
df['Time'] = df['date_column'].dt.strftime('%I:%M:%S %p')


```