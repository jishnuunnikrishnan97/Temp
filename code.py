import re

def remove_extra_newlines(input_string):
    # Use regular expression to replace consecutive "\n" with a single "\n"
    cleaned_string = re.sub('\n+', '\n', input_string)

    # Remove leading and trailing "\n"
    cleaned_string = cleaned_string.strip('\n')

    return cleaned_string
