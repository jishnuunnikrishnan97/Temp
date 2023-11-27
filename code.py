import re

def remove_recurring_lines(input_text):
    # Define the pattern to match the recurring lines
    pattern = re.compile(r'\nversion: Aug 2006 page \d+ of \d+\n')

    # Use the pattern to replace matching lines with an empty string
    cleaned_text = re.sub(pattern, '', input_text)

    return cleaned_text
    
