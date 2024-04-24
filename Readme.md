
```

import os
import pandas as pd

# Define the input folder path
input_folder = os.path.join(os.getcwd(), 'Input')

# Get a list of files in the input folder
folder_name = os.listdir(input_folder)

# Iterate over each file in the directory
for file in folder_name:
    print("Processing file:", file)  # Debug: show which file is being processed

    # Initialize the date variable
    date = ''

    # Check if the file ends with 'XLS' and contains 'GSEC_POSITION_REPORT' in its name
    if file.endswith('XLS') and 'GSEC_POSITION_REPORT' in file:

        # Load the Excel file into a DataFrame
        df = pd.read_excel(os.path.join(input_folder, file))

        # Select the first row
        df = df.iloc[0:1]

        # Drop columns where all values are NaN
        df = df.dropna(axis=1, how='all')

        # Drop rows where all values are NaN
        df = df.dropna(axis=0, how='all')

        # Extract the date value from the DataFrame
        date = df.values[0][0]  # Assuming the date is in the first cell
        parts = date.split()
        date = parts[2]  # Extracting the day part of the date

        # Print the extracted date
        print("Extracted date:", date)



```