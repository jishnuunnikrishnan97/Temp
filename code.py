import re

def remove_recurring_string(input_string):
    pattern = r"\nMaster Services Agreement v\d+\.\d+ [A-Za-z]+ \d+ \n(?: \n)*Confidential and Subject to Contract\. \n(?: \n)*\d+"
    result = re.sub(pattern, "", input_string)
    return result

# Example usage:
input_string = "Your_long_input_string_here"
cleaned_string = remove_recurring_string(input_string)
print(cleaned_string)
