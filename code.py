def replace_single_newline(input_string):
    # Use regular expression to find consecutive "\n" and count them
    matches = re.findall('\n+', input_string)
    
    # Replace single "\n" with a space if there is no consecutive occurrence
    cleaned_string = re.sub('(?<!\n)\n(?!\n)', ' ', input_string)

    return cleaned_string