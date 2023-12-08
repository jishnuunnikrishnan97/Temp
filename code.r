import re

def split_paragraphs(input_text): 
    pattern = re.compile(r'\nARTICLE \d+\.\s*-\s*[^\n]+ \n')  # Updated regex pattern

    paragraphs = pattern.split(input_text)
    headings = pattern.findall(input_text)

    # Remove empty strings from the list
    paragraphs = [para.strip() for para in paragraphs if para.strip()]

    # Combine paragraphs and headings
    result = [{'heading': heading, 'paragraph': paragraph} for heading, paragraph in zip(headings, paragraphs)]

    return result
