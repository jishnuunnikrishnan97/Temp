import re

def custom_newline_replacement(input_string):
    # Identify and store occurrences of "ARTICLE" between two "\n"
    article_matches = re.findall('\nARTICLE\n', input_string)

    # Replace "\n" not after "." with a space, ignoring spaces between "." and "\n"
    cleaned_string = re.sub('(?<!\.)\n(?!ARTICLE\n)', ' ', input_string)

    # Restore occurrences of "ARTICLE" between two "\n"
    for match in article_matches:
        cleaned_string = cleaned_string.replace(match, '\nARTICLE\n')

    return cleaned_string

# Example usage:
input_string = "This is a\nsample.\n\nARTICLE\nText with\nnewlines.\nAnother.\nARTICLE\nMore text.\n"
result = custom_newline_replacement(input_string)
print(result)
