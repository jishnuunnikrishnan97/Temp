```

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

```