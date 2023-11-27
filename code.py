import re

def modify_string(input_string):
    # Replace "\n" with space if there is no "." before it
    cleaned_string = re.sub('(?<!\.)\n(?! )', ' ', input_string)

    # Add "." before the last "\n" after "ARTICLE" between two "\n"
    cleaned_string = re.sub('\nARTICLE\n', '.\n', cleaned_string)

    return cleaned_string

# Example usage:
input_string = "This is a\nsample ARTICLE\nstring\nwith\nnewlines.\n"
result = modify_string(input_string)
print(result)
