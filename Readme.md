```
import pandas as pd
from datetime import datetime

# Sample DataFrame
dicto = pd.DataFrame({
    'PIN ENTERED': ['12:34:55', '13:45:22', None, '14:23:05'],
    'RESPONSE RECEIVED': ['12:35:30', '13:45:55', '14:30:10', None]
})

# Function to convert strings to timedelta
def convert_to_timedelta(time_str):
    if pd.isnull(time_str):
        return None
    return datetime.strptime(time_str, '%H:%M:%S') - datetime(1900, 1, 1)

# Apply the function to both columns
dicto['PIN_ENTERED_TIME'] = dicto['PIN ENTERED'].apply(convert_to_timedelta)
dicto['RESPONSE_RECEIVED_TIME'] = dicto['RESPONSE RECEIVED'].apply(convert_to_timedelta)

# Calculate the difference
dicto['DIFFERENCE'] = dicto.apply(
    lambda row: (row['RESPONSE_RECEIVED_TIME'] - row['PIN_ENTERED_TIME']).total_seconds() 
    if pd.notnull(row['PIN_ENTERED_TIME']) and pd.notnull(row['RESPONSE_RECEIVED_TIME']) 
    else None, axis=1
)

# Convert the difference into MM:SS format
dicto['DIFFERENCE_MM_SS'] = dicto['DIFFERENCE'].apply(
    lambda x: f"{int(x // 60):02}:{int(x % 60):02}" if pd.notnull(x) else None
)

# Drop the extra columns (optional)
dicto = dicto.drop(columns=['PIN_ENTERED_TIME', 'RESPONSE_RECEIVED_TIME', 'DIFFERENCE'])

# Display the updated DataFrame
print(dicto)


```