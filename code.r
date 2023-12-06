import re

def extract_pattern(text):
    pattern = re.compile(r'\n\d+\.\s\w+\s*\n')
    match = pattern.search(text)

    if match:
        start_index = match.end()
        result = text[start_index:]
        return result
    else:
        return "Pattern not found in the given string."

# Example usage:
input_text = "Some text before\n3. Terms \nThis is the content you want to keep."
result = extract_pattern(input_text)
print(result)
