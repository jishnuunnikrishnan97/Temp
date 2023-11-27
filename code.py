import re

def replace_newlines_with_conditions(input_string):
    # Use regular expression to replace "\n" based on conditions
    cleaned_string = re.sub(r'(?<=[.])\s*\n\s*|\n(?=ARTICLE)', ' ', input_string)

    return cleaned_string

# Example usage:
input_string = "This is a sample.\n\nARTICLE\nwith newlines.\nAnother\n\nARTICLE\nsection."
result = replace_newlines_with_conditions(input_string)
print(result)
