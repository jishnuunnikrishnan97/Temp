import re

def split_paragraphs(input_text):
    pattern = re.compile(r'\n\d+\.\s\w+')

    paragraphs = pattern.split(input_text)
    headings = pattern.findall(input_text)

    # Remove empty strings from the list
    paragraphs = [para.strip() for para in paragraphs if para.strip()]

    # Combine paragraphs and headings
    result = [{'heading': heading, 'paragraph': paragraph} for heading, paragraph in zip(headings, paragraphs)]

    return result

# Example usage:
input_text = "\n1. Definition Some text here.\n2. Terms More text for terms.\n3. Indemnification Final text for indemnification."
result = split_paragraphs(input_text)
print(result)
