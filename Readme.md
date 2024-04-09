import pandas as pd

# Sample DataFrame with "Difference" column
data = {'Difference': [pd.Timedelta(minutes=15), pd.Timedelta(minutes=45), 
                       pd.Timedelta(hours=1, minutes=30), pd.Timedelta(hours=3),
                       pd.Timedelta(hours=5, minutes=45)]}
df = pd.DataFrame(data)

# Function to count occurrences in different time ranges
def count_occurrences(time_delta_column):
    # Initialize counters for different time ranges
    range_10_30 = 0
    range_30_60 = 0
    range_1_2_hours = 0
    range_2_9_hours = 0
    
    # Iterate through the values in the column
    for time_delta in time_delta_column:
        # Convert timedelta to minutes
        total_minutes = time_delta.total_seconds() / 60
        
        # Check the time range and update counters accordingly
        if 10 <= total_minutes <= 30:
            range_10_30 += 1
        elif 30 < total_minutes <= 60:
            range_30_60 += 1
        elif 60 < total_minutes <= 120:
            range_1_2_hours += 1
        elif 120 < total_minutes <= 540:
            range_2_9_hours += 1
    
    # Return the counts for each time range
    return {
        '10-30 minutes': range_10_30,
        '30-60 minutes': range_30_60,
        '1-2 hours': range_1_2_hours,
        '2-9 hours': range_2_9_hours
    }

# Call the function with the "Difference" column and print the result
result = count_occurrences(df['Difference'])
print(result)
