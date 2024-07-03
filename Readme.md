```

import pandas as pd
from datetime import timedelta

# Create the dataframe
data = {'crdate': ['2024-05-10T11:50:15.250+08:00',
                   '2024-05-10T11:58:38.324+08:00',
                   '2024-05-10T11:58:55.045+08:00',
                   '2024-05-10T13:02:29.493+08:00',
                   '2024-05-10T12:09:27.719+08:00',
                   '2024-05-10T12:14:00.215+08:00']}
df1 = pd.DataFrame(data)

# Split the 'crdate' column into 'Date' and 'Time' columns
df1['Date'] = df1['crdate'].str[:10]
df1['Time'] = df1['crdate'].str[11:19]

# Convert 'Date' and 'Time' columns to datetime
df1['DateTime'] = pd.to_datetime(df1['Date'] + ' ' + df1['Time'])

# Subtract 2 hours and 30 minutes to get 'Time IST'
df1['Time IST'] = df1['DateTime'] - timedelta(hours=2, minutes=30)

# Define the time range
start_time = pd.Timestamp('09:00:00').time()
end_time = pd.Timestamp('21:00:00').time()

# Create 'B/A' column with condition
df1['B/A'] = df1['Time IST'].apply(lambda x: 'Before/After' if x.time() < start_time or x.time() > end_time else '')

# Display the result
print(df1[['crdate', 'Date', 'Time', 'Time IST', 'B/A']])



```