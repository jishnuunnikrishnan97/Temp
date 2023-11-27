import re

def modify_article_string(input_string):
    # Use regular expression to find "ARTICLE" between two "\n"
    article_pattern = re.compile(r'\n(.*ARTICLE.*\n)(.*\n)', re.DOTALL)

    # Check if the pattern is present and modify the string accordingly
    match = article_pattern.search(input_string)
    if match:
        modified_string = input_string.replace(match.group(0), match.group(1).rstrip('.') + '.\n' + match.group(2).replace('\n', ' '))
    else:
        modified_string = re.sub('(?<!\.)\n(?! )', ' ', input_string)

    return modified_string

# Example usage:
input_string = "\nArticle 2. - fund replacement\nThis is a\nsample ARTICLE string\nwith\nnewlines.\nAnother ARTICLE example.\n"
result = modify_article_string(input_string)
print(result)
