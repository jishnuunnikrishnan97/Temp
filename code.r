import re

def remove_before_pattern(input_text):
    pattern = re.compile(r'.*?(\n\d+\.\s(?:Terms|Terminologies)\s*\n)')

    match = re.search(pattern, input_text)

    if match:
        start_index = match.end(1)
        result = input_text[start_index:]
        return result
    else:
        return input_text

# Example usage:
input_text = "Some text before\n3. Terms \nYour content here."
result = remove_before_pattern(input_text)
print(result)
