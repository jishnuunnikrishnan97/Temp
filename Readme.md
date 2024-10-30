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


```