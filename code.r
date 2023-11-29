import re

def clean_string(input_string):
    # Remove unwanted spaces, newlines, |, _, and \x0c
    cleaned_string = re.sub(r'^\s*|\s*$', '', input_string)
    cleaned_string = re.sub(r'\n|\x0c|\||_', '', cleaned_string)

    return cleaned_string

# Example usage:
bell = " \n\nBank Name\n\x0c"
cleaned_result = clean_string(bell)
print(cleaned_result)
