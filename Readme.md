```

Claude

def extract_log_data(data_list):
    """
    Extracts specific fields from a list of log strings and formats them into a dictionary
    where each key has a list of values from all log entries.
    
    Args:
        data_list (list): List of strings containing log data
        
    Returns:
        dict: Dictionary with specified fields as keys and lists of extracted values
    """
    # Initialize the result dictionary with empty lists for each field
    result = {
        'USER ID': [],
        'DEPARTMENT': [],
        'DEPARTMENT ID': [],
        'FUNCTION': [],
        'DATE': [],
        'TELEPHONE - OFFICE': []
    }
    
    for log_string in data_list:
        try:
            # Extract DATE (everything before TIME)
            date_match = log_string.split('TIME:')[0]
            if 'DATE:' in date_match:
                date = date_match.split('DATE:')[1].strip()
                result['DATE'].append(date)
            
            # Extract FUNCTION (everything before DEPARTMENT)
            function_match = log_string.split('DEPARTMENT:')[0]
            if 'FUNCTION:' in function_match:
                function = function_match.split('FUNCTION:')[1].strip()
                result['FUNCTION'].append(function)
            
            # Extract DEPARTMENT (everything before USER)
            dept_match = log_string.split('USER:')[0]
            if 'DEPARTMENT:' in dept_match:
                dept = dept_match.split('DEPARTMENT:')[1].strip()
                result['DEPARTMENT'].append(dept)
            
            # For fields that end with newline, we'll split by field name and then by newline
            # Extract DEPARTMENT ID
            if 'DEPARTMENT ID' in log_string:
                dept_id = log_string.split('DEPARTMENT ID')[1].split('\n')[0].strip()
                result['DEPARTMENT ID'].append(dept_id)
            
            # Extract USER ID
            if 'USER ID' in log_string:
                user_id = log_string.split('USER ID')[1].split('\n')[0].strip()
                result['USER ID'].append(user_id)
            
            # Extract TELEPHONE - OFFICE
            if 'TELEPHONE - OFFICE' in log_string:
                tel = log_string.split('TELEPHONE - OFFICE')[1].split('\n')[0].strip()
                result['TELEPHONE - OFFICE'].append(tel)
            
        except Exception as e:
            print(f"Error processing a log entry: {str(e)}")
            continue
    
    # Clean up the extracted values by removing any remaining whitespace or special characters
    for key in result:
        result[key] = [value.strip() for value in result[key] if value.strip()]
    
    return result

# Example usage:
# result_dict = extract_log_data(dataList)
# 
# # To validate the results:
# for key, values in result_dict.items():
#     print(f"{key}: {values}")



GPT

import re

def extract_data(dataList):
    # Initialize the dictionary to store the extracted data
    output = {
        'USER ID': [],
        'DEPARTMENT': [],
        'DEPARTMENT ID': [],
        'FUNCTION': [],
        'DATE': [],
        'TELEPHONE - OFFICE': []
    }

    # Iterate over each string in the dataList
    for data in dataList:
        # Extract the required fields using regular expressions
        date_match = re.search(r'DATE:\s*(.*?)\s*TIME:', data)
        function_match = re.search(r'FUNCTION:\s*(.*?)\s*DEPARTMENT:', data)
        department_match = re.search(r'DEPARTMENT:\s*(.*?)\s*USER:', data)
        department_id_match = re.search(r'DEPARTMENT ID\s*(.*?)\n', data)
        user_id_match = re.search(r'USER ID\s*(.*?)\n', data)
        telephone_office_match = re.search(r'TELEPHONE - OFFICE\s*(.*?)\n', data)

        # Append the extracted data to the output dictionary
        if date_match:
            output['DATE'].append(date_match.group(1).strip())
        if function_match:
            output['FUNCTION'].append(function_match.group(1).strip())
        if department_match:
            output['DEPARTMENT'].append(department_match.group(1).strip())
        if department_id_match:
            output['DEPARTMENT ID'].append(department_id_match.group(1).strip())
        if user_id_match:
            output['USER ID'].append(user_id_match.group(1).strip())
        if telephone_office_match:
            output['TELEPHONE - OFFICE'].append(telephone_office_match.group(1).strip())

    return output

# Example usage
dataList = [
    "\n DATE: 24/04/24 TIME: 19:17:16 SEGMENT: IXQDBATH FUNCTION: DELETE DEPARTMENT: 00811 USER: CNIDM02 TERMINAL: V44N FILE: STATIC DAT\n LOG ROOT KEY :\n-----------------------------------------------------------------------------------------\n ATH-ENTITY                   002\n DEPARTMENT ID                   00161\n USER ID                   BBAWYMA\n SECTION                   OR\n NAME - ENGLISH                   Mahata, Pranay\n NAME - LOCAL                   Mahata, Pranay\n PASSWORD                   ******\n TELEPHONE - OFFICE                   TODEB001\n EFFECTIVE DATE                   2023/03/08\n EXPIRY DATE                   2069/12/31\n IMP L/C (DEPT AUTH) 3\n IMP S/G (DEPT AUTH) 3\n IMP COL (DEPT AUTH) 3\n"
]

# Extracted data
result = extract_data(dataList)
print(result)

_______________________

import pandas as pd
import re

# Step 1: Load Excel file
# Replace 'file_path.xlsx' with the actual file path of your Excel file.
df = pd.read_excel('file_path.xlsx')

# Step 2: Define a function to extract IMEXID and UserGroup values from the XML string
def extract_values(order_details):
    # Define patterns to find the values for IMEXID and UserGroup
    imexid_pattern = r'<Key>IMEXID</Key>\s*<Value>(.*?)</Value>'
    usergroup_pattern = r'<Key>UserGroup</Key>\s*<Value>(.*?)</Value>'
    
    # Use regex to search for the values in the string
    imexid_match = re.search(imexid_pattern, order_details)
    usergroup_match = re.search(usergroup_pattern, order_details)
    
    # Extract values if found, otherwise return None
    imexid = imexid_match.group(1) if imexid_match else None
    usergroup = usergroup_match.group(1) if usergroup_match else None
    
    return imexid, usergroup

# Step 3: Apply the function to the 'Order Details' column and create new columns
df[['IMEXID', 'User Group']] = df['Order Details'].apply(lambda x: pd.Series(extract_values(x)))

# Display the DataFrame to verify the results
print(df)

# Step 4: (Optional) Save the DataFrame back to Excel if needed
df.to_excel('output_file.xlsx', index=False)


---------------------

import pandas as pd

def find_sheets_with_txn(file_path):
    # Load the Excel file to get sheet names
    xls = pd.ExcelFile(file_path)
    
    # Filter sheet names containing 'txn' (case-insensitive)
    txn_sheets = [sheet for sheet in xls.sheet_names if 'txn' in sheet.lower()]
    
    return txn_sheets

# Example usage:
# file_path = "path/to/your/excel_file.xlsx"
# print(find_sheets_with_txn(file_path))

------------------------
import pandas as pd

# Sample data for df1 and df2
data1 = {
    'CSID': [1, 2, 3],
    'Approval Date': ['2023-01-01', '2023-01-02', '2023-01-03'],
    'Acess Role_ID': [101, 102, 103],
    'User Group': ['GroupA', 'GroupB', 'GroupC'],
    'Action': ['Read', 'Write', 'Execute']
}
df1 = pd.DataFrame(data1)

data2 = {
    'PTID': [1, 2, 3],
    'Date': ['2023-01-01', '2023-01-02', '2023-01-04'],
    'Department ID': [101, 105, 103],
    'Telephone': ['GroupA', 'GroupB', 'GroupD'],
    'Function': ['read', 'write', 'delete']
}
df2 = pd.DataFrame(data2)

# Step 1: Merge df1 and df2 on 'CSID' and 'PTID'
merged_df = pd.merge(df1, df2, left_on='CSID', right_on='PTID', how='left', suffixes=('', '_df2'))

# Step 2: Define matching conditions
def match_columns(row):
    matched_columns = []

    # Checking conditions and appending matched columns
    if row['Approval Date'] == row['Date']:
        matched_columns.append('Date')
    if row['Acess Role_ID'] == row['Department ID']:
        matched_columns.append('Department ID')
    if row['User Group'] == row['Telephone']:
        matched_columns.append('Telephone')
    if row['Action'].lower() == row['Function']:
        matched_columns.append('Function')
    
    # If any matched columns are found, return them; else return None
    return ', '.join(matched_columns) if matched_columns else None

# Apply matching function to find matches and populate 'Matched Columns' and 'RPT remark'
merged_df['Matched Columns'] = merged_df.apply(match_columns, axis=1)
merged_df['RPT remark'] = merged_df['Matched Columns'].apply(lambda x: 'Match Found' if x else None)

# Select only required columns for final df1 with the new columns
df1_final = merged_df[['CSID', 'Approval Date', 'Acess Role_ID', 'User Group', 'Action', 'RPT remark', 'Matched Columns']]
print(df1_final)

-------------------------------------------


import pandas as pd

# Sample data for df1 and df2 for demonstration (replace with your actual data)
df1 = pd.DataFrame({
    'CSID': [1, 2, 3, 4],
    'Action': ['Delete', 'Create', 'Delete', 'Create'],
    'Date': ['2023-01-01', '2023-01-02', '2023-01-01', '2023-01-02']
})

df2 = pd.DataFrame({
    'PTID': [1, 1, 2, 3, 3, 3],
    'Action_Type': ['REMOVE USER', 'REMOVE USER', 'CREATE USER', 'CREATE USER', 'CREATE USER', 'CREATE USER'],
    'Date': ['2023-01-01', '2023-01-01', '2023-01-02', '2023-01-02', '2023-01-02', '2023-01-02']
})

# Initialize the Remarks column with empty strings or 'Query' by default
df1['Remarks'] = ''

# Convert dates to datetime for accurate comparison
df1['Date'] = pd.to_datetime(df1['Date'])
df2['Date'] = pd.to_datetime(df2['Date'])

# Condition 1: Check if Action is 'Delete' in df1 and matches with 'REMOVE USER' in df2 along with matching dates
for i, row in df1.iterrows():
    csid = row['CSID']
    action = row['Action']
    date = row['Date']
    
    # Check if CSID is present in df2's PTID
    if csid not in df2['PTID'].values:
        df1.at[i, 'Remarks'] = 'Query'
        continue
    
    if action == 'Delete':
        # Find matching rows in df2 based on PTID, Action_Type, and Date
        condition = (df2['PTID'] == csid) & (df2['Action_Type'] == 'REMOVE USER') & (df2['Date'] == date)
        if not df2[condition].any().any():  # If no matching rows are found, set 'Query'
            df1.at[i, 'Remarks'] = 'Query'
    
    elif action == 'Create':
        # Check if there are 3 or more occurrences of the same PTID with matching date in df2
        create_condition = (df2['PTID'] == csid) & (df2['Date'] == date)
        if df2[create_condition].shape[0] < 3:  # If less than 3 matches are found, set 'Query'
            df1.at[i, 'Remarks'] = 'Query'

# Display the final result with Remarks column populated
print(df1)

--------------------

import pandas as pd

# Sample DataFrame
data = {
    'Col1': ['A', 'B', 'C', 'D'],
    'Action': ['INSERT', 'RANDOM', 'DELETE', 'UPDATE'],
    'Col3': ['X1', 'Y1', 'Z1', 'W1'],
    'Col4': ['X2', 'Y2', 'Z2', 'W2'],
}

df = pd.DataFrame(data)

# Define the function to shift rows
def shift_row_data_left(df):
    # Iterate through the DataFrame
    for index, row in df.iterrows():
        if row['Action'] not in ['INSERT', 'UPDATE', 'DELETE']:
            # Shift row data by one column to the left
            shifted_row = row.iloc[1:].values  # Exclude the first column
            shifted_row = list(shifted_row) + [None]  # Add None to fill the last column
            # Update the first column with concatenated data
            df.at[index, 'Col1'] = f"{row['Col1']} {shifted_row[0]}"
            # Update the rest of the row with shifted data
            df.iloc[index, 1:] = shifted_row
    return df

# Apply the function
df = shift_row_data_left(df)
print(df)


-------------------------

import pandas as pd
from datetime import datetime, timedelta

# Sample DataFrames
data_ipe = {
    '1Bank ID': [101, 102, 103],
    'Approval Date': ['2024-11-15', '2024-11-14', '2024-11-13'],
    'Approval Time': ['12:00:05', '14:30:10', '09:15:25']
}

data_main = {
    'USERID': [201, 102, 103],
    'Created Date': ['2024-11-15', '2024-11-14', '2024-11-13'],
    'Created Time': ['12:00:10', '14:30:05', '09:15:15']
}

ipe_xl = pd.DataFrame(data_ipe)
main_df = pd.DataFrame(data_main)

# Convert date and time columns to datetime
ipe_xl['Approval DateTime'] = pd.to_datetime(ipe_xl['Approval Date'] + ' ' + ipe_xl['Approval Time'])
main_df['Created DateTime'] = pd.to_datetime(main_df['Created Date'] + ' ' + main_df['Created Time'])

# Function to check matching conditions
def match_rows(row):
    bank_id = row['1Bank ID']
    approval_datetime = row['Approval DateTime']
    
    # Filter main_df for matching USERID
    filtered_main = main_df[main_df['USERID'] == bank_id]
    
    if not filtered_main.empty:
        # Compare datetime differences
        for _, main_row in filtered_main.iterrows():
            time_diff = abs((approval_datetime - main_row['Created DateTime']).total_seconds())
            if time_diff <= 10:
                return None  # Match found, return nothing
    return 'Application not found in UAMS'  # No match found

# Apply function to ipe_xl
ipe_xl['Match Status'] = ipe_xl.apply(match_rows, axis=1)

# Drop temporary column if needed
ipe_xl.drop(columns=['Approval DateTime'], inplace=True)

# Display result
print(ipe_xl)

----------------------

import pandas as pd

def process_numeric_id(value):
    """
    Process numeric IDs by converting to string, removing decimal, and adding leading zero if needed.
    """
    if pd.isna(value):
        return value
    # Convert to string and remove decimal part
    str_val = str(int(float(value)))
    # Add leading zero if length is 2
    return '0' + str_val if len(str_val) == 2 else str_val

def process_datetime(df, column):
    """
    Process datetime columns by converting to datetime and handling spaces.
    """
    if df[column].dtype == 'object':  # If column is string
        # Strip spaces and convert to datetime
        return pd.to_datetime(df[column].str.strip())
    else:
        # If already datetime or other type, just convert to datetime
        return pd.to_datetime(df[column])

def process_dataframes(fin_xl, main_df):
    """
    Process both dataframes according to the specified requirements.
    """
    # Create copies to avoid modifying original dataframes
    fin_xl = fin_xl.copy()
    main_df = main_df.copy()
    
    # Process 'sol id' and 'workclass' in fin_xl
    fin_xl['sol id'] = fin_xl['sol id'].apply(process_numeric_id)
    fin_xl['workclass'] = fin_xl['workclass'].apply(process_numeric_id)
    
    # Process datetime columns
    main_df['Indian Time'] = process_datetime(main_df, 'Indian Time')
    fin_xl['Approval Date'] = process_datetime(fin_xl, 'Approval Date')
    
    # Process 'operation' column - remove leading/trailing spaces
    fin_xl['operation'] = fin_xl['operation'].str.strip()
    
    return fin_xl, main_df

# Example usage:
# processed_fin_xl, processed_main_df = process_dataframes(fin_xl, main_df)

-------------------

import pandas as pd
import numpy as np
from datetime import timedelta

def check_time_match(time1, time2, threshold_seconds=60):
    """
    Check if two datetime values are within the specified threshold.
    """
    if pd.isna(time1) or pd.isna(time2):
        return False
    return abs((time1 - time2).total_seconds()) <= threshold_seconds

def process_create_action(row, fin_xl):
    """
    Process rows where Action is 'Create'.
    """
    # Find matching workclass rows
    matching_rows = fin_xl[fin_xl['workclass'] == row['Workclass']]
    
    if matching_rows.empty:
        return 'Query'
    
    # Case 1a: operation is 'A'
    a_rows = matching_rows[matching_rows['operation'] == 'A']
    if not a_rows.empty:
        for _, fin_row in a_rows.iterrows():
            if check_time_match(row['Indian Time'], fin_row['rcre_time']):
                return 'Pass'
    
    # Case 1b: operation is 'M'
    m_rows = matching_rows[matching_rows['operation'] == 'M']
    if not m_rows.empty:
        for _, m_row in m_rows.iterrows():
            # Find corresponding 'U' row for same userid with null values
            u_rows = fin_xl[
                (fin_xl['userid'] == m_row['userid']) &
                (fin_xl['operation'] == 'U') &
                (fin_xl[['solid', 'workclass', 'empid']].isna().all(axis=1))
            ]
            
            if not u_rows.empty:
                # Check if the M row has non-null values and time matches
                if not pd.isna(m_row[['solid', 'workclass', 'empid']]).any():
                    if check_time_match(row['Indian Time'], m_row['rcre_time']):
                        return 'Pass'
    
    return 'Query'

def process_modify_action(row, fin_xl):
    """
    Process rows where Action is 'Modify'.
    """
    matching_rows = fin_xl[
        (fin_xl['workclass'] == row['Workclass']) &
        (fin_xl['operation'] == 'M')
    ]
    
    if matching_rows.empty:
        return 'Query'
    
    for _, fin_row in matching_rows.iterrows():
        if check_time_match(row['Indian Time'], fin_row['rcre_time']):
            return 'Pass'
    
    return 'Query'

def process_delete_action(row, fin_xl):
    """
    Process rows where Action is 'Delete'.
    """
    matching_rows = fin_xl[
        (fin_xl['workclass'] == row['Workclass']) &
        (fin_xl['operation'] == 'D')
    ]
    
    if matching_rows.empty:
        return 'Query'
    
    for _, fin_row in matching_rows.iterrows():
        if check_time_match(row['Indian Time'], fin_row['rcre_time']):
            return 'Pass'
    
    return 'Query'

def match_dataframes(main_df, fin_xl):
    """
    Main function to process all rows and create the Comment column.
    """
    # Create a copy of main_df to avoid modifying the original
    main_df = main_df.copy()
    
    # Initialize Comment column
    main_df['Comment'] = 'Query'
    
    # Process each row based on Action
    for idx, row in main_df.iterrows():
        if row['Action'] == 'Create':
            main_df.at[idx, 'Comment'] = process_create_action(row, fin_xl)
        elif row['Action'] == 'Modify':
            main_df.at[idx, 'Comment'] = process_modify_action(row, fin_xl)
        elif row['Action'] == 'Delete':
            main_df.at[idx, 'Comment'] = process_delete_action(row, fin_xl)
    
    return main_df

# Example usage:
# result_df = match_dataframes(main_df, fin_xl)

--------------------
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Example initialization of dataframes
# Replace with actual data
fin_xl = pd.DataFrame({
    'sol id': [1.0, 10.0, 110.0, np.nan],
    'workclass': [2.0, 20.0, 210.0, np.nan],
    'Approval Date': ['2023-11-01', '2023-11-05', '2023-11-15', ' '],
    'operation': [' A ', 'M', 'U', np.nan],
    '1BankID': [123, 456, 789, None],
    'rcre_time': ['2023-11-19 14:30:00', '2023-11-19 14:35:00', '2023-11-19 14:40:00', None],
    'userid': ['abc', 'def', np.nan, None],
    'empid': [np.nan, 123, np.nan, None],
})

main_df = pd.DataFrame({
    'Action': ['Create', 'Modify', 'Delete'],
    'Workclass': [20.0, 2.0, 210.0],
    '1Bank ID': [456, 123, 789],
    'Indian Time': ['2023-11-19 14:35:01 ', '2023-11-19 14:29:50', '2023-11-19 14:40:05'],
})

# 1. Data Cleaning Tasks
# Function to safely convert to int and add leading zero
def clean_and_pad(column):
    return column.apply(lambda x: str(int(float(x))).zfill(3) if pd.notna(x) and str(x).strip() != '' else None)

# Apply cleaning to 'sol id' and 'workclass'
fin_xl['sol id'] = clean_and_pad(fin_xl['sol id'])
fin_xl['workclass'] = clean_and_pad(fin_xl['workclass'])

# Convert 'Indian Time' and 'Approval Date' to datetime, removing spaces if needed
main_df['Indian Time'] = pd.to_datetime(main_df['Indian Time'].str.strip(), errors='coerce')
fin_xl['Approval Date'] = pd.to_datetime(fin_xl['Approval Date'].str.strip(), errors='coerce')

# Remove spaces from 'operation'
fin_xl['operation'] = fin_xl['operation'].str.strip()

# 2. Logic-Based Tasks
def match_rows(row):
    action = row['Action']
    workclass = str(int(float(row['Workclass']))).zfill(3) if pd.notna(row['Workclass']) else None
    bank_id = row['1Bank ID']
    indian_time = row['Indian Time']
    
    if not workclass or pd.isna(bank_id) or pd.isna(indian_time):
        return 'Query'
    
    # Filter matching rows in fin_xl
    matches = fin_xl[(fin_xl['workclass'] == workclass) & (fin_xl['1BankID'] == bank_id)]
    
    if action == 'Create':
        if not matches.empty:
            create_matches = matches[matches['operation'] == 'A']
            if not create_matches.empty:
                for _, match_row in create_matches.iterrows():
                    # Match Indian Time with threshold of 60 seconds
                    rcre_time = pd.to_datetime(match_row['rcre_time'], errors='coerce')
                    if pd.notna(rcre_time) and abs((indian_time - rcre_time).total_seconds()) <= 60:
                        return 'Pass'
    elif action == 'Modify':
        if not matches.empty:
            modify_matches = matches[matches['operation'] == 'M']
            if not modify_matches.empty:
                for _, match_row in modify_matches.iterrows():
                    # Match Indian Time with threshold of 60 seconds
                    rcre_time = pd.to_datetime(match_row['rcre_time'], errors='coerce')
                    if pd.notna(rcre_time) and abs((indian_time - rcre_time).total_seconds()) <= 60:
                        return 'Pass'
    elif action == 'Delete':
        if not matches.empty:
            delete_matches = matches[matches['operation'] == 'D']
            if not delete_matches.empty():
                for _, match_row in delete_matches.iterrows():
                    # Match Indian Time with threshold of 60 seconds
                    rcre_time = pd.to_datetime(match_row['rcre_time'], errors='coerce')
                    if pd.notna(rcre_time) and abs((indian_time - rcre_time).total_seconds()) <= 60:
                        return 'Pass'
    
    return 'Query'

# Apply the logic to main_df
main_df['Comment'] = main_df.apply(match_rows, axis=1)

# Display the updated main_df
print(main_df)

======================================


import pandas as pd
from datetime import datetime, timedelta

# Sample DataFrames (Replace with actual data)
main_df = pd.DataFrame({
    'Action': ['Create', 'Modify', 'Delete'],
    'Workclass': ['A', 'B', 'C'],
    '1Bank ID': [101, 102, 103],
    'Indian Time': ['2024-11-19 10:00:00', '2024-11-19 10:05:00', '2024-11-19 10:10:00']
})
fin_xl = pd.DataFrame({
    'workclass': ['A', 'B', 'C'],
    '1BankID': [101, 102, 103],
    'operation': ['A', 'M', 'D'],
    'rcre_time': ['2024-11-19 10:00:30', '2024-11-19 10:05:20', '2024-11-19 10:10:50'],
    'userid': [1, 2, None],
    'solid': [1, None, None],
    'empid': [1, None, None]
})

# Convert time columns to datetime
main_df['Indian Time'] = pd.to_datetime(main_df['Indian Time'])
fin_xl['rcre_time'] = pd.to_datetime(fin_xl['rcre_time'])

# Initialize the Comment column
main_df['Comment'] = 'Query'

# Threshold for time difference in seconds
threshold = timedelta(seconds=60)

# Function to process rows
def process_row(row):
    action = row['Action']
    workclass = row['Workclass']
    bank_id = row['1Bank ID']
    indian_time = row['Indian Time']

    if action == 'Create':
        # Condition for 'A'
        matches_a = fin_xl[
            (fin_xl['workclass'] == workclass) &
            (fin_xl['1BankID'] == bank_id) &
            (fin_xl['operation'] == 'A') &
            (abs(fin_xl['rcre_time'] - indian_time) <= threshold)
        ]
        if not matches_a.empty:
            return 'Pass'

        # Condition for 'M' and 'U'
        matches_m = fin_xl[
            (fin_xl['workclass'] == workclass) &
            (fin_xl['1BankID'] == bank_id) &
            (fin_xl['operation'] == 'M')
        ]
        for _, match in matches_m.iterrows():
            matches_u = fin_xl[
                (fin_xl['userid'] == match['userid']) &
                (fin_xl['operation'] == 'U') &
                (fin_xl[['solid', 'workclass', 'empid']].isnull().all(axis=1))
            ]
            if not matches_u.empty and abs(match['rcre_time'] - indian_time) <= threshold:
                return 'Pass'

    elif action == 'Modify':
        # Condition for 'M'
        matches_m = fin_xl[
            (fin_xl['workclass'] == workclass) &
            (fin_xl['1BankID'] == bank_id) &
            (fin_xl['operation'] == 'M') &
            (abs(fin_xl['rcre_time'] - indian_time) <= threshold)
        ]
        if not matches_m.empty:
            return 'Pass'

    elif action == 'Delete':
        # Condition for 'D'
        matches_d = fin_xl[
            (fin_xl['workclass'] == workclass) &
            (fin_xl['1BankID'] == bank_id) &
            (fin_xl['operation'] == 'D') &
            (abs(fin_xl['rcre_time'] - indian_time) <= threshold)
        ]
        if not matches_d.empty:
            return 'Pass'

    return 'Query'

# Apply the function to main_df
main_df['Comment'] = main_df.apply(process_row, axis=1)

print(main_df)


============================

import pandas as pd

def unmerge_and_fill(df: pd.DataFrame, column_name: str) -> pd.DataFrame:
    """
    Unmerges cells in a specified column and forward fills the values.
    
    Parameters:
    -----------
    df : pd.DataFrame
        The input DataFrame containing merged cells
    column_name : str
        The name of the column containing merged cells to be filled
        
    Returns:
    --------
    pd.DataFrame
        DataFrame with the specified column unmerged and filled
    """
    # Create a copy to avoid modifying the original DataFrame
    df_cleaned = df.copy()
    
    # Forward fill the specified column
    df_cleaned[column_name] = df_cleaned[column_name].ffill()
    
    # Reset the index if needed
    df_cleaned = df_cleaned.reset_index(drop=True)
    
    return df_cleaned

# Example usage for multiple columns
def clean_merged_columns(df: pd.DataFrame, columns: list) -> pd.DataFrame:
    """
    Handles multiple columns with merged cells.
    
    Parameters:
    -----------
    df : pd.DataFrame
        The input DataFrame containing merged cells
    columns : list
        List of column names to process
        
    Returns:
    --------
    pd.DataFrame
        DataFrame with all specified columns unmerged and filled
    """
    df_result = df.copy()
    
    for column in columns:
        if column in df.columns:
            df_result = unmerge_and_fill(df_result, column)
            
    return df_result

=======================================


import pandas as pd

# Sample data for demonstration
df1 = pd.DataFrame({
    'Role': ['Admin', 'User', 'Guest'],
    'Role Desc': ['Administrator', 'Regular User', 'Guest User'],
    'Entity': ['Global', 'Region1', 'Region2'],
    'Dept001': ['Normal', 'üPresent', 'Normal'],
    'Dept002': ['Normal', 'Normal', 'Normal']
})

df2 = pd.DataFrame({
    'Department Code': ['Dept001', 'Dept003'],
    'User Group': ['Admin', 'Guest'],
    'User Group_Desc': ['Administrator', 'Guest User'],
    'Access Role_ID': ['Global', 'Region2']
})

# Step 1: Check if df2['Department Code'] exists in df1 column names
df2['ACM Comment'] = 'Match Not Found'  # Default value
for index, row in df2.iterrows():
    dept_code = row['Department Code']
    user_group = row['User Group']
    user_group_desc = row['User Group_Desc']
    access_role_id = row['Access Role_ID']
    
    if dept_code in df1.columns:
        # Step 2: Search for df2[['User Group', 'User Group_Desc', 'Access Role_ID']] in df1[['Role', 'Role Desc', 'Entity']]
        matched_rows = df1[
            (df1['Role'] == user_group) & 
            (df1['Role Desc'] == user_group_desc) & 
            (df1['Entity'] == access_role_id)
        ]
        
        # Step 3: Check the matched column for character 'ü'
        if not matched_rows.empty and 'ü' in matched_rows.iloc[0][dept_code]:
            # Step 4: Update df2['ACM Comment']
            df2.at[index, 'ACM Comment'] = 'Match found'

# Result
print(df2)



import pandas as pd

# Sample DataFrames
# df1: Replace with your actual data
df1 = pd.DataFrame({
    'Role': ['Admin', 'User', 'Manager'],
    'Role Desc': ['Admin Role', 'User Role', 'Manager Role'],
    'Entity': ['E1', 'E2', 'E3'],
    'Dept_001': ['abc', 'def', 'üghi'],  # Example column
    'Dept_002': ['üjkl', 'mno', 'pqr']
})

# df2: Replace with your actual data
df2 = pd.DataFrame({
    'User Group': ['Admin', 'User', 'Manager'],
    'User Group_Desc': ['Admin Role', 'User Role', 'Manager Role'],
    'Access Role_ID': ['E1', 'E2', 'E3'],
    'Department Code': ['Dept_001', 'Dept_003', 'Dept_002']
})

# Step 1: Check if 'Department Code' exists in df1 columns
def check_and_comment(df1, df2):
    comments = []
    for _, row in df2.iterrows():
        dept_code = row['Department Code']
        
        if dept_code in df1.columns:
            # Step 2: Check for match in Role, Role Desc, and Entity
            match = df1[
                (df1['Role'] == row['User Group']) &
                (df1['Role Desc'] == row['User Group_Desc']) &
                (df1['Entity'] == row['Access Role_ID'])
            ]
            
            if not match.empty:
                # Step 3: Check for 'ü' character in the matched column
                if any(match[dept_code].str.contains('ü', na=False)):
                    comments.append('Match found')
                    continue
        comments.append('Match Not Found')
    
    df2['ACM Comment'] = comments
    return df2

# Apply the function
df2 = check_and_comment(df1, df2)

# Display the updated df2
print(df2)

==========================

import pandas as pd

# Example dataframes
data1 = {
    'User Group': ['A1', 'A2', 'A3', 'A4'],
    'Dept1': ['ü', 'x', 'y', 'z'],
    'Dept2': ['a', 'ü', 'c', 'd'],
}
df1 = pd.DataFrame(data1)

data2 = {
    'Department Code': ['Dept1', 'Dept2', 'Dept3'],
    'User Group': ['A1', 'A3', 'A5'],
}
df2 = pd.DataFrame(data2)

# Task implementation
def check_matches(df1, df2):
    comments = []
    for _, row in df2.iterrows():
        dept_code = row['Department Code']
        user_group = row['User Group']
        
        # Step 1: Check if Department Code exists in df1 columns
        if dept_code in df1.columns:
            # Step 2: Check if User Group exists in df1[df1.columns[1]]
            if user_group in df1[df1.columns[0]].values:
                # Find the row in df1 where the match is found
                matched_row = df1[df1[df1.columns[0]] == user_group]
                # Step 3: Check for 'ü' in the matched column
                if 'ü' in matched_row[dept_code].values:
                    comments.append('Match found')
                    continue
        comments.append('Match Not Found')
    
    # Step 4: Add ACM Comment column to df2
    df2['ACM Comment'] = comments
    return df2

# Apply the function
df2 = check_matches(df1, df2)

# Print the result
print(df2)


def check_conditions(row):
    match = main_df[main_df['USERID'] == row['USERID']]
    if not match.empty:
        matched_row = match.iloc[0]
        if (row['Action'] == 'Delete' and 
            matched_row['Action_Type'] == 'REMOVE USER' and 
            row['Approval Date'] == matched_row['LOG_DATE']):
            return 'Pass'
    return 'Query'

# Apply the conditions to the 'Remarks' column
murex_xl['Remarks'] = murex_xl.apply(check_conditions, axis=1)


```